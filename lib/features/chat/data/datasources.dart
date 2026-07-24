import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

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
}

/// Relay en vivo de mensajes de chat sobre el mismo socket de notificaciones
/// (`realtime/` multiplexa ambos con un discriminador `event` en el
/// payload). Conecta una sola vez por sesión (stream broadcast, lazy) y
/// reutiliza la conexión para todas las conversaciones abiertas -- no hay
/// lógica de reconexión automática (fuera de alcance del MVP: si el socket
/// cae, el usuario reabre la pantalla).
class ChatWebSocketDataSource {
  final ApiClient _client;
  WebSocketChannel? _channel;
  Stream<ChatMessageModel>? _broadcastStream;

  ChatWebSocketDataSource(this._client);

  Stream<ChatMessageModel> chatMessages() {
    return _broadcastStream ??= _connect().asBroadcastStream();
  }

  Stream<ChatMessageModel> _connect() async* {
    final token = await _client.getToken();
    if (token == null) return;

    _channel = WebSocketChannel.connect(Uri.parse('${RealtimeConfig.wsUrl}?token=$token'));
    await for (final raw in _channel!.stream) {
      Map<String, dynamic>? decoded;
      try {
        decoded = jsonDecode(raw as String) as Map<String, dynamic>;
      } catch (_) {
        continue;
      }
      if (decoded['event'] != 'chat_message') continue;
      yield ChatMessageModel.fromJson(decoded);
    }
  }

  void dispose() {
    _channel?.sink.close();
    _channel = null;
    _broadcastStream = null;
  }
}
