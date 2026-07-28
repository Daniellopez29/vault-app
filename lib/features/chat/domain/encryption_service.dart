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
  /// Genera un par de llaves RSA para [userId]. La privada se guardará en
  /// almacenamiento seguro (en un slot propio de esa cuenta); la pública se
  /// comparte con el servidor.
  Future<Either<Failure, KeyPairEntity>> generateKeyPair(String userId);

  /// Cifra un mensaje para DOS destinatarios de la misma llave AES: el
  /// receptor real (con [recipientPublicKey]) y el propio emisor (con
  /// [senderPublicKey], para poder releer su propio envío más tarde).
  /// cipherText/iv son los mismos para ambos -- solo cambia cómo se
  /// envuelve la llave AES.
  Future<Either<Failure, EncryptedMessageEntity>> encryptMessage({
    required String plainText,
    required String recipientPublicKey,
    required String senderPublicKey,
  });

  /// Descifra con la llave privada propia. [encryptedAesKey] debe ser la
  /// envoltura correcta para esa privada -- el llamador decide cuál de las
  /// dos (`encryptedAesKey` o `encryptedAesKeySender`) corresponde según si
  /// el mensaje es ajeno o propio (ver ChatRepositoryImpl).
  Future<Either<Failure, String>> decryptMessage({
    required String cipherText,
    required String encryptedAesKey,
    required String iv,
    required String ownPrivateKey,
  });
}
