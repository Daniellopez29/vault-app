import 'package:dartz/dartz.dart';

import '../../../core/error.dart';
import 'crypto/key_store.dart';
import '../domain/encryption_service.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';
import 'datasources.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remote;
  final ChatWebSocketDataSource _ws;
  final EncryptionService _encryption;
  final KeyStore _keyStore;

  ChatRepositoryImpl({
    required ChatRemoteDataSource remote,
    required ChatWebSocketDataSource ws,
    required EncryptionService encryption,
    KeyStore? keyStore,
  })  : _remote = remote,
        _ws = ws,
        _encryption = encryption,
        _keyStore = keyStore ?? KeyStore();

  @override
  Future<Either<Failure, void>> ensurePublicKeyRegistered(String userId) async {
    try {
      // El storage del par RSA es del dispositivo, no de la cuenta: si el
      // par guardado le pertenece a OTRO usuario (sesión anterior en este
      // mismo teléfono), no se puede reusar -- se genera uno nuevo para
      // este usuario, si no dos cuentas terminarían compartiendo una sola
      // llave privada.
      final owner = await _keyStore.readOwnerId();
      var publicKey = owner == userId ? await _keyStore.readPublicKey() : null;
      if (publicKey == null) {
        final generated = await _encryption.generateKeyPair();
        if (generated.isLeft()) {
          return generated.fold((f) => Left(f), (_) => const Right(null));
        }
        await _keyStore.setOwnerId(userId);
        publicKey = await _keyStore.readPublicKey();
      }
      if (publicKey == null) {
        return const Left(ServerFailure('No se pudo generar la llave de cifrado.'));
      }
      await _remote.registerPublicKey(userId, publicKey);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Error al preparar el cifrado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> getConversation(String otherUserId) async {
    try {
      final messages = await _remote.getConversation(otherUserId);
      final privateKey = await _keyStore.readPrivateKey();
      final resolved = <MessageEntity>[];
      for (final message in messages) {
        // En una conversación 1 a 1, todo mensaje que no vino del otro
        // participante es mío -- así se sabe qué llave envuelve la AES sin
        // necesitar el propio id por separado.
        final fromOther = message.senderId == otherUserId;
        resolved.add(await _withPlainText(
          message,
          privateKey?.toString(),
          useSenderKey: !fromOther,
        ));
      }
      return Right(resolved);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Error al cargar la conversación: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ConversationSummaryEntity>>> getConversations() async {
    try {
      final summaries = await _remote.getConversations();
      final privateKey = await _keyStore.readPrivateKey();
      final resolved = <ConversationSummaryEntity>[];
      for (final summary in summaries) {
        final fromOther = summary.lastMessage.senderId == summary.otherUserId;
        final lastMessage = await _withPlainText(
          summary.lastMessage,
          privateKey?.toString(),
          useSenderKey: !fromOther,
        );
        resolved.add(ConversationSummaryEntity(
          otherUserId: summary.otherUserId,
          otherUserName: summary.otherUserName,
          otherUserAvatarUrl: summary.otherUserAvatarUrl,
          lastMessage: lastMessage,
          unreadCount: summary.unreadCount,
        ));
      }
      return Right(resolved);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Error al cargar tus conversaciones: $e'));
    }
  }

  @override
  Future<Either<Failure, MessageEntity>> sendMessage({
    required String recipientId,
    required String plainText,
  }) async {
    try {
      final recipientPublicKey = await _remote.getPublicKey(recipientId);
      if (recipientPublicKey == null) {
        return const Left(
          ServerFailure('El destinatario aún no tiene el chat configurado.'),
        );
      }
      final ownPublicKey = await _keyStore.readPublicKey();
      if (ownPublicKey == null) {
        return const Left(
          ServerFailure('Tu cifrado todavía no está listo, intenta de nuevo en un momento.'),
        );
      }

      final encryptedResult = await _encryption.encryptMessage(
        plainText: plainText,
        recipientPublicKey: recipientPublicKey,
        senderPublicKey: ownPublicKey,
      );
      return await encryptedResult.fold(
        (failure) async => Left(failure),
        (encrypted) async {
          final sent = await _remote.sendMessage(recipientId: recipientId, encrypted: encrypted);
          // Ya sé lo que escribí -- no hace falta descifrar nada aquí.
          return Right(MessageEntity(
            id: sent.id,
            senderId: sent.senderId,
            encryptedContent: sent.encryptedContent,
            timestamp: sent.timestamp,
            status: sent.status,
            plainText: plainText,
          ));
        },
      );
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Error al enviar el mensaje: $e'));
    }
  }

  @override
  Stream<MessageEntity> incomingMessages() {
    // Todo lo que llega por WS viene dirigido a mí (el backend solo hace
    // relay al recipient_id) -- siempre uso encryptedAesKey, nunca la
    // envoltura "para emisor".
    return _ws.chatMessages().asyncMap((message) async {
      final privateKey = await _keyStore.readPrivateKey();
      return _withPlainText(message, privateKey?.toString(), useSenderKey: false);
    });
  }

  /// Intenta descifrar con la privada propia, usando la envoltura correcta
  /// de la llave AES ([useSenderKey] = true para mensajes que yo envié,
  /// false para mensajes ajenos). Si falla, devuelve el mensaje tal cual,
  /// con `plainText` en null.
  Future<MessageEntity> _withPlainText(
    MessageEntity message,
    String? ownPrivateKey, {
    required bool useSenderKey,
  }) async {
    if (ownPrivateKey == null) return message;

    final keyToUse = useSenderKey
        ? message.encryptedContent.encryptedAesKeySender
        : message.encryptedContent.encryptedAesKey;
    if (keyToUse.isEmpty) return message;

    final decrypted = await _encryption.decryptMessage(
      cipherText: message.encryptedContent.cipherText,
      encryptedAesKey: keyToUse,
      iv: message.encryptedContent.iv,
      ownPrivateKey: ownPrivateKey,
    );
    return decrypted.fold(
      (_) => message,
      (text) => MessageEntity(
        id: message.id,
        senderId: message.senderId,
        encryptedContent: message.encryptedContent,
        timestamp: message.timestamp,
        status: message.status,
        plainText: text,
      ),
    );
  }
}
