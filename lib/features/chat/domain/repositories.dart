import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import 'entities.dart';

/// Acceso al chat E2EE: registro de llaves públicas, envío/historial por
/// REST (persistencia real), y mensajes entrantes en vivo por WebSocket.
///
/// El cifrado/descifrado ocurre DENTRO de la implementación (usa
/// [EncryptionService] y [KeyStore]) -- la presentación solo ve texto plano
/// ya resuelto en [MessageEntity]. El servidor nunca ve ese texto plano.
abstract class ChatRepository {
  /// Genera el par de llaves si el dispositivo no tiene uno, y lo registra
  /// en el backend. Seguro de llamar repetidas veces (idempotente).
  Future<Either<Failure, void>> ensurePublicKeyRegistered(String userId);

  /// Historial de la conversación con [otherUserId], ya descifrado.
  Future<Either<Failure, List<MessageEntity>>> getConversation(String otherUserId);

  /// Cifra [plainText] con la pública de [recipientId] y lo manda.
  Future<Either<Failure, MessageEntity>> sendMessage({
    required String recipientId,
    required String plainText,
  });

  /// Mensajes nuevos entrantes de cualquier conversación, ya descifrados
  /// con la privada propia. El llamador filtra por el remitente que le
  /// interesa.
  Stream<MessageEntity> incomingMessages();
}
