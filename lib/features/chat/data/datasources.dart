import '../../../core/api_client.dart';
import '../../../core/error.dart';
import '../domain/entities.dart';
import 'models.dart';

abstract class ChatRemoteDataSource {
  Future<ChatMessageModel> sendMessage({
    required String recipientId,
    required EncryptedMessageEntity encrypted,
  });
  Future<List<ChatMessageModel>> getConversation(String otherUserId);
  Future<List<ConversationSummaryModel>> getConversations();
  Future<void> registerPublicKey(String userId, String publicKey);

  /// `null` si el usuario todavía no registró ninguna llave pública.
  Future<String?> getPublicKey(String userId);

  /// Marca un mensaje como leído (para que baje del contador de no leídos
  /// en la bandeja de conversaciones).
  Future<void> markAsRead(String messageId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final ApiClient _client;

  ChatRemoteDataSourceImpl(this._client);

  @override
  Future<ChatMessageModel> sendMessage({
    required String recipientId,
    required EncryptedMessageEntity encrypted,
  }) async {
    try {
      final body = await _client.post('/chat/messages', body: {
        'recipient_id': recipientId,
        'cipher_text': encrypted.cipherText,
        'encrypted_aes_key': encrypted.encryptedAesKey,
        'encrypted_aes_key_sender': encrypted.encryptedAesKeySender,
        'iv': encrypted.iv,
      });
      return ChatMessageModel.fromJson(body as Map<String, dynamic>);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al enviar el mensaje: $e');
    }
  }

  @override
  Future<List<ChatMessageModel>> getConversation(String otherUserId) async {
    try {
      final body = await _client.get('/conversations/$otherUserId/messages');
      final list = body as List<dynamic>? ?? const [];
      return list.map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>)).toList();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al cargar la conversación: $e');
    }
  }

  @override
  Future<List<ConversationSummaryModel>> getConversations() async {
    try {
      final body = await _client.get('/conversations');
      final list = body as List<dynamic>? ?? const [];
      return list
          .map((e) => ConversationSummaryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al cargar tus conversaciones: $e');
    }
  }

  @override
  Future<void> registerPublicKey(String userId, String publicKey) async {
    try {
      await _client.post('/users/$userId/public-key', body: {'public_key': publicKey});
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al registrar la llave pública: $e');
    }
  }

  @override
  Future<String?> getPublicKey(String userId) async {
    try {
      final body = await _client.get('/users/$userId/public-key', auth: false);
      return (body as Map<String, dynamic>)['public_key'] as String?;
    } on Failure {
      return null;
    } catch (e) {
      throw ServerFailure('Error al obtener la llave pública del destinatario: $e');
    }
  }

  @override
  Future<void> markAsRead(String messageId) async {
    try {
      await _client.patch('/chat/messages/$messageId/status', body: {'status': 'read'});
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al marcar el mensaje como leído: $e');
    }
  }
}
