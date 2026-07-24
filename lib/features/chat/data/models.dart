import '../domain/entities.dart';

/// Respuesta de POST /chat/messages, GET /conversations/{id}/messages y
/// PATCH /chat/messages/{id}/status del API Go. `plainText` nunca viene del
/// backend -- lo resuelve [ChatRepositoryImpl] al descifrar.
class ChatMessageModel extends MessageEntity {
  const ChatMessageModel({
    required super.id,
    required super.senderId,
    required super.encryptedContent,
    required super.timestamp,
    required super.status,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      encryptedContent: EncryptedMessageEntity(
        cipherText: json['cipher_text'] as String,
        encryptedAesKey: json['encrypted_aes_key'] as String,
        encryptedAesKeySender: json['encrypted_aes_key_sender'] as String? ?? '',
        iv: json['iv'] as String,
      ),
      timestamp: DateTime.parse(json['created_at'] as String),
      status: _statusFrom(json['status'] as String? ?? 'sent'),
    );
  }

  static MessageStatus _statusFrom(String value) {
    switch (value) {
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      default:
        return MessageStatus.sent;
    }
  }
}

/// Respuesta de GET /conversations del API Go.
class ConversationSummaryModel extends ConversationSummaryEntity {
  const ConversationSummaryModel({
    required super.otherUserId,
    required super.otherUserName,
    required super.otherUserAvatarUrl,
    required super.lastMessage,
    required super.unreadCount,
  });

  factory ConversationSummaryModel.fromJson(Map<String, dynamic> json) {
    return ConversationSummaryModel(
      otherUserId: json['other_user_id'] as String,
      otherUserName: json['other_user_name'] as String? ?? '',
      otherUserAvatarUrl: json['other_user_avatar_url'] as String? ?? '',
      lastMessage: ChatMessageModel.fromJson(
        json['last_message'] as Map<String, dynamic>,
      ),
      unreadCount: json['unread_count'] as int? ?? 0,
    );
  }
}
