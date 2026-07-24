import 'package:equatable/equatable.dart';

/// Una conversación entre dos participantes (1 a 1 por ahora).
/// Guarda las llaves públicas de cada participante para poder cifrar.
class ConversationEntity extends Equatable {
  final String id;
  final List<String> participantIds;
  final Map<String, String> publicKeys; // participantId -> llave pública
  final DateTime? lastMessageAt;

  const ConversationEntity({
    required this.id,
    required this.participantIds,
    required this.publicKeys,
    this.lastMessageAt,
  });

  @override
  List<Object?> get props => [id, participantIds, publicKeys, lastMessageAt];
}

/// Estado de entrega de un mensaje.
enum MessageStatus { sent, delivered, read }

/// Un mensaje de la conversación. Lo que se guarda y viaja es
/// encryptedContent; [plainText] lo resuelve el repositorio al descifrar
/// con la llave privada propia -- y por diseño del esquema híbrido
/// (la llave AES solo se cifra con la pública del RECEPTOR), un mensaje que
/// YO envié no lo puedo volver a descifrar con mi propia privada: para esos
/// [plainText] queda en `null` salvo que se haya mandado en esta misma
/// sesión (ver ChatRepositoryImpl.sendMessage), que ya conoce el texto sin
/// necesidad de descifrar nada.
class MessageEntity extends Equatable {
  final String id;
  final String senderId;
  final EncryptedMessageEntity encryptedContent;
  final DateTime timestamp;
  final MessageStatus status;
  final String? plainText;

  const MessageEntity({
    required this.id,
    required this.senderId,
    required this.encryptedContent,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.plainText,
  });

  @override
  List<Object?> get props =>
      [id, senderId, encryptedContent, timestamp, status, plainText];
}

/// Una fila de la bandeja de chat: la última conversación con cada persona,
/// para [ConversationsListPage]. El servidor nunca ve el texto plano, así
/// que [lastMessage] puede llegar sin descifrar si la privada propia no
/// puede abrir esa envoltura (ver [ChatRepositoryImpl._withPlainText]).
class ConversationSummaryEntity extends Equatable {
  final String otherUserId;
  final String otherUserName;
  final String otherUserAvatarUrl;
  final MessageEntity lastMessage;
  final int unreadCount;

  const ConversationSummaryEntity({
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserAvatarUrl,
    required this.lastMessage,
    required this.unreadCount,
  });

  @override
  List<Object?> get props =>
      [otherUserId, otherUserName, otherUserAvatarUrl, lastMessage, unreadCount];
}

/// El par de llaves del usuario. La privada NUNCA sale del dispositivo;
/// se modela aquí pero se almacena en flutter_secure_storage.
class KeyPairEntity extends Equatable {
  final String publicKey;
  final String privateKey;

  const KeyPairEntity({
    required this.publicKey,
    required this.privateKey,
  });

  @override
  List<Object?> get props => [publicKey, privateKey];
}

/// El contenido cifrado de un mensaje (esquema híbrido RSA + AES).
/// - cipherText: mensaje cifrado con AES.
/// - encryptedAesKey: la llave AES cifrada con la pública RSA del receptor.
/// - encryptedAesKeySender: la MISMA llave AES, cifrada además con la
///   pública RSA del propio emisor -- sin esto, quien envía un mensaje no
///   podría releerlo después (su privada no destraba una llave cifrada
///   para la pública del receptor). cipherText/iv son los mismos para
///   ambas envolturas, solo cambia cuál llave RSA se usó para cifrar la AES.
/// - iv: vector de inicialización del AES (aleatorio por mensaje).
/// Es lo único que existe en tránsito y en el servidor.
class EncryptedMessageEntity extends Equatable {
  final String cipherText;
  final String encryptedAesKey;
  final String encryptedAesKeySender;
  final String iv;

  const EncryptedMessageEntity({
    required this.cipherText,
    required this.encryptedAesKey,
    required this.encryptedAesKeySender,
    required this.iv,
  });

  Map<String, dynamic> toMap() => {
        'cipherText': cipherText,
        'encryptedAesKey': encryptedAesKey,
        'encryptedAesKeySender': encryptedAesKeySender,
        'iv': iv,
      };

  factory EncryptedMessageEntity.fromMap(Map<String, dynamic> map) {
    return EncryptedMessageEntity(
      cipherText: map['cipherText'] as String,
      encryptedAesKey: map['encryptedAesKey'] as String,
      encryptedAesKeySender: map['encryptedAesKeySender'] as String,
      iv: map['iv'] as String,
    );
  }

  @override
  List<Object?> get props => [cipherText, encryptedAesKey, encryptedAesKeySender, iv];
}
