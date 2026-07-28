import 'dart:developer' as dev;

import 'package:dartz/dartz.dart';

import '../../../core/error.dart';
import '../../../core/realtime_socket.dart';
import 'crypto/key_store.dart';
import '../domain/encryption_service.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';
import 'datasources.dart';
import 'models.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remote;
  final RealtimeSocket _ws;
  final EncryptionService _encryption;
  final KeyStore _keyStore;

  /// Fijado por [ensurePublicKeyRegistered], que main.dart llama una vez por
  /// cada inicio de sesión antes de que se pueda llegar a ninguna pantalla
  /// de chat -- lo usan el resto de los métodos para leer el slot de llaves
  /// que le corresponde a esta cuenta (ver KeyStore).
  String? _currentUserId;

  ChatRepositoryImpl({
    required ChatRemoteDataSource remote,
    required RealtimeSocket ws,
    required EncryptionService encryption,
    KeyStore? keyStore,
  })  : _remote = remote,
        _ws = ws,
        _encryption = encryption,
        _keyStore = keyStore ?? KeyStore();

  @override
  Future<Either<Failure, void>> ensurePublicKeyRegistered(String userId) async {
    _currentUserId = userId;
    try {
      // KeyStore guarda un slot de llaves propio por cuenta -- no hace
      // falta comparar "dueños" acá, cada userId tiene el suyo.
      var publicKey = await _keyStore.readPublicKey(userId);
      if (publicKey == null) {
        final generated = await _encryption.generateKeyPair(userId);
        if (generated.isLeft()) {
          return generated.fold((f) => Left(f), (_) => const Right(null));
        }
        publicKey = await _keyStore.readPublicKey(userId);
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
      final privateKey = await _ownPrivateKeyString();
      final resolved = <MessageEntity>[];
      for (final message in messages) {
        // En una conversación 1 a 1, todo mensaje que no vino del otro
        // participante es mío -- así se sabe qué llave envuelve la AES sin
        // necesitar el propio id por separado.
        final fromOther = message.senderId == otherUserId;
        resolved.add(await _withPlainText(
          message,
          privateKey,
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
      final privateKey = await _ownPrivateKeyString();
      final resolved = <ConversationSummaryEntity>[];
      for (final summary in summaries) {
        final fromOther = summary.lastMessage.senderId == summary.otherUserId;
        final lastMessage = await _withPlainText(
          summary.lastMessage,
          privateKey,
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
      final ownPublicKey = await _ownPublicKey();
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
    return _ws
        .events()
        .where((e) => e['event'] == 'chat_message')
        .map(ChatMessageModel.fromJson)
        .asyncMap((message) async {
      final privateKey = await _ownPrivateKeyString();
      return _withPlainText(message, privateKey, useSenderKey: false);
    });
  }

  @override
  Future<Either<Failure, void>> markMessagesAsRead(List<String> messageIds) async {
    if (messageIds.isEmpty) return const Right(null);
    try {
      // Best-effort: si un mensaje individual falla, no vale la pena
      // reventar toda la operación por eso (mismo criterio que el backend
      // usa para notificaciones -- ver SendChatMessageUseCase.go).
      await Future.wait(messageIds.map(_remote.markAsRead));
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Error al marcar mensajes como leídos: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMessage(String messageId) async {
    try {
      await _remote.deleteMessage(messageId);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Error al eliminar el mensaje: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteConversation(String otherUserId) async {
    try {
      await _remote.deleteConversation(otherUserId);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Error al eliminar la conversación: $e'));
    }
  }

  Future<String?> _ownPrivateKeyString() async {
    final userId = _currentUserId;
    if (userId == null) {
      // Si esto se ve en los logs, ensurePublicKeyRegistered todavía no
      // corrió para esta cuenta -- todo lo que dependa de la privada
      // (descifrar mensajes) va a fallar en silencio hasta que corra.
      dev.log('_ownPrivateKeyString: _currentUserId es null', name: 'chat_e2ee');
      return null;
    }
    final key = await _keyStore.readPrivateKey(userId);
    if (key == null) {
      dev.log('_ownPrivateKeyString: no hay privada guardada para $userId', name: 'chat_e2ee');
    }
    return key?.toString();
  }

  Future<String?> _ownPublicKey() async {
    final userId = _currentUserId;
    if (userId == null) {
      dev.log('_ownPublicKey: _currentUserId es null', name: 'chat_e2ee');
      return null;
    }
    final key = await _keyStore.readPublicKey(userId);
    if (key == null) {
      dev.log('_ownPublicKey: no hay pública guardada para $userId', name: 'chat_e2ee');
    }
    return key;
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
    if (keyToUse.isEmpty) {
      // El mensaje llegó sin la envoltura AES que le tocaba (senderKey o
      // recipientKey, según useSenderKey) -- distinto de una privada que no
      // coincide, esto es un dato faltante del lado del servidor/mensaje.
      dev.log(
        'mensaje ${message.id}: falta ${useSenderKey ? "encrypted_aes_key_sender" : "encrypted_aes_key"}',
        name: 'chat_e2ee',
      );
      return message;
    }

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
