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
/// encryptedContent; el texto plano solo existe en memoria al cifrar/descifrar.
class MessageEntity extends Equatable {
  final String id;
  final String senderId;
  final EncryptedMessageEntity encryptedContent;
  final DateTime timestamp;
  final MessageStatus status;

  const MessageEntity({
    required this.id,
    required this.senderId,
    required this.encryptedContent,
    required this.timestamp,
    this.status = MessageStatus.sent,
  });

  @override
  List<Object?> get props =>
      [id, senderId, encryptedContent, timestamp, status];
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
/// - iv: vector de inicialización del AES (aleatorio por mensaje).
/// Es lo único que existe en tránsito y en el servidor.
class EncryptedMessageEntity extends Equatable {
  final String cipherText;
  final String encryptedAesKey;
  final String iv;

  const EncryptedMessageEntity({
    required this.cipherText,
    required this.encryptedAesKey,
    required this.iv,
  });

  Map<String, dynamic> toMap() => {
        'cipherText': cipherText,
        'encryptedAesKey': encryptedAesKey,
        'iv': iv,
      };

  factory EncryptedMessageEntity.fromMap(Map<String, dynamic> map) {
    return EncryptedMessageEntity(
      cipherText: map['cipherText'] as String,
      encryptedAesKey: map['encryptedAesKey'] as String,
      iv: map['iv'] as String,
    );
  }

  @override
  List<Object?> get props => [cipherText, encryptedAesKey, iv];
}
