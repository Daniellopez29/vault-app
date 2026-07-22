import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import 'entities.dart';

/// Contrato del servicio de cifrado E2EE (definido en domain, según la
/// arquitectura de Vault). La implementación concreta (RSA+AES) vive en data.
///
/// La presentación nunca toca este servicio directamente: solo el repositorio
/// de chat lo usa. La UI trabaja con MessageEntity ya descifrado.
///
/// Regla de oro: la llave privada nunca sale del dispositivo; el servidor
/// nunca ve texto plano.
abstract class EncryptionService {
  /// Genera un par de llaves RSA. La privada se guardará en almacenamiento
  /// seguro; la pública se comparte con el servidor.
  Future<Either<Failure, KeyPairEntity>> generateKeyPair();

  /// Cifra un mensaje para un receptor usando SU llave pública.
  /// Devuelve el contenido cifrado (AES + llave AES cifrada con RSA + IV).
  Future<Either<Failure, EncryptedMessageEntity>> encryptMessage({
    required String plainText,
    required String recipientPublicKey,
  });

  /// Descifra un mensaje usando la llave privada propia.
  /// Devuelve el texto plano (solo existe en memoria, aquí).
  Future<Either<Failure, String>> decryptMessage({
    required EncryptedMessageEntity encryptedMessage,
    required String ownPrivateKey,
  });
}
