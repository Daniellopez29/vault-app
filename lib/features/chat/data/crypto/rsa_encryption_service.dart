import 'dart:developer' as dev;

import 'package:crypton/crypton.dart';
import 'package:dartz/dartz.dart';
import 'package:encrypt/encrypt.dart' as enc;
import '../../../../core/error.dart';
import '../../domain/entities.dart';
import '../../domain/encryption_service.dart';
import 'key_store.dart';

/// Implementación del E2EE con esquema híbrido RSA + AES.
///
/// Por qué híbrido: RSA no cifra textos largos (solo datos pequeños), pero es
/// ideal para compartir un secreto. AES cifra cualquier tamaño rápido. Por cada
/// mensaje se genera una llave AES nueva, se cifra el texto con AES, y se cifra
/// esa llave AES con la pública RSA del receptor. Solo su privada podrá leerlo.
///
/// Nada hardcodeado: llave AES e IV se generan aleatorios por mensaje; las
/// llaves RSA se generan en el dispositivo y la privada nunca sale.
class RsaEncryptionService implements EncryptionService {
  final KeyStore _keyStore;

  RsaEncryptionService({KeyStore? keyStore}) : _keyStore = keyStore ?? KeyStore();

  @override
  Future<Either<Failure, KeyPairEntity>> generateKeyPair(String userId) async {
    try {
      final publicKey = await _keyStore.generateAndStore(userId);
      final privateKey = await _keyStore.readPrivateKey(userId);
      if (privateKey == null) {
        return const Left(ServerFailure('No se pudo generar el par de llaves.'));
      }
      return Right(KeyPairEntity(
        publicKey: publicKey,
        privateKey: privateKey.toString(),
      ));
    } catch (_) {
      return const Left(ServerFailure('Error al generar las llaves.'));
    }
  }

  @override
  Future<Either<Failure, EncryptedMessageEntity>> encryptMessage({
    required String plainText,
    required String recipientPublicKey,
    required String senderPublicKey,
  }) async {
    try {
      // Llave AES e IV nuevos y aleatorios para ESTE mensaje -- se
      // reutilizan para ambas envolturas RSA de abajo.
      final aesKey = enc.Key.fromSecureRandom(32); // AES-256
      final iv = enc.IV.fromSecureRandom(16);
      final encrypter = enc.Encrypter(enc.AES(aesKey, mode: enc.AESMode.cbc));

      // Ciframos el texto con AES.
      final cipherText = encrypter.encrypt(plainText, iv: iv).base64;

      // Ciframos la llave AES con la pública RSA del receptor, y por
      // separado con la propia -- así el emisor también puede releer su
      // mensaje después.
      final encryptedAesKey =
          RSAPublicKey.fromString(recipientPublicKey).encrypt(aesKey.base64);
      final encryptedAesKeySender =
          RSAPublicKey.fromString(senderPublicKey).encrypt(aesKey.base64);

      return Right(EncryptedMessageEntity(
        cipherText: cipherText,
        encryptedAesKey: encryptedAesKey,
        encryptedAesKeySender: encryptedAesKeySender,
        iv: iv.base64,
      ));
    } catch (_) {
      return const Left(ServerFailure('Error al cifrar el mensaje.'));
    }
  }

  @override
  Future<Either<Failure, String>> decryptMessage({
    required String cipherText,
    required String encryptedAesKey,
    required String iv,
    required String ownPrivateKey,
  }) async {
    try {
      final privateKey = RSAPrivateKey.fromString(ownPrivateKey);

      // Recuperamos la llave AES con la privada RSA.
      final aesKeyBase64 = privateKey.decrypt(encryptedAesKey);
      final aesKey = enc.Key.fromBase64(aesKeyBase64);
      final ivObj = enc.IV.fromBase64(iv);
      final encrypter = enc.Encrypter(enc.AES(aesKey, mode: enc.AESMode.cbc));

      // Con esa llave AES, desciframos el texto.
      final plainText = encrypter.decrypt64(cipherText, iv: ivObj);
      return Right(plainText);
    } catch (e, st) {
      // El error real se registra (no se le muestra al usuario, sigue
      // mostrando "mensaje cifrado") -- sin esto, cuando falla acá no hay
      // forma de saber si fue la privada que no coincide, la llave AES mal
      // formada, o el padding del texto, y "revisa los logs" no servía de
      // nada porque no había nada que revisar.
      dev.log('decryptMessage falló: $e', name: 'chat_e2ee', error: e, stackTrace: st);
      return const Left(ServerFailure('Error al descifrar el mensaje.'));
    }
  }
}

