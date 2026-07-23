import 'package:crypton/crypton.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_test/flutter_test.dart';
import 'package:vault_app/features/chat/domain/entities.dart';

/// Prueba del E2EE híbrido RSA + AES con las entidades del dominio de Vault.
///
/// Simula a Ana (emisora) y Beto (receptor). Ana cifra usando SOLO la llave
/// pública de Beto; solo la privada de Beto puede descifrar.
void main() {
  test('E2EE: Ana cifra para Beto y solo Beto puede leer', () {
    // Ana y Beto generan su par. Solo comparten la pública.
    final ana = RSAKeypair.fromRandom();
    final beto = RSAKeypair.fromRandom();
    final anaPublicKey = ana.publicKey.toString();
    final betoPublicKey = beto.publicKey.toString();

    const mensajeOriginal = 'Hola Beto, este mensaje es secreto 🔒';

    // === ANA cifra ===
    // La misma llave AES se envuelve DOS veces: una con la pública de
    // Beto (para que él lea el mensaje), y otra con la propia pública de
    // Ana (para que ella pueda releerlo después -- sin esto, una vez
    // enviado, ni siquiera la autora podría volver a verlo).
    final aesKey = enc.Key.fromSecureRandom(32);
    final iv = enc.IV.fromSecureRandom(16);
    final encrypter = enc.Encrypter(enc.AES(aesKey, mode: enc.AESMode.cbc));
    final cipherText = encrypter.encrypt(mensajeOriginal, iv: iv).base64;
    final encryptedAesKey =
        RSAPublicKey.fromString(betoPublicKey).encrypt(aesKey.base64);
    final encryptedAesKeySender =
        RSAPublicKey.fromString(anaPublicKey).encrypt(aesKey.base64);

    // Lo que viaja por la red = la entidad del dominio.
    final payload = EncryptedMessageEntity(
      cipherText: cipherText,
      encryptedAesKey: encryptedAesKey,
      encryptedAesKeySender: encryptedAesKeySender,
      iv: iv.base64,
    );

    print('=== Lo que vería el servidor (ilegible) ===');
    print('cipherText: ${payload.cipherText}');
    print('encryptedAesKey: ${payload.encryptedAesKey.substring(0, 40)}...');
    print('');

    // El cifrado no revela el mensaje.
    expect(payload.cipherText.contains('Beto'), isFalse);
    expect(payload.cipherText.contains('secreto'), isFalse);

    // === BETO descifra con su envoltura ===
    final aesKeyRecuperada = beto.privateKey.decrypt(payload.encryptedAesKey);
    final aesKey2 = enc.Key.fromBase64(aesKeyRecuperada);
    final iv2 = enc.IV.fromBase64(payload.iv);
    final encrypter2 = enc.Encrypter(enc.AES(aesKey2, mode: enc.AESMode.cbc));
    final mensajeDescifrado = encrypter2.decrypt64(payload.cipherText, iv: iv2);

    print('=== Lo que lee Beto (con su llave privada) ===');
    print('Mensaje: $mensajeDescifrado');

    expect(mensajeDescifrado, equals(mensajeOriginal));

    // === ANA también puede releer su propio mensaje, con SU envoltura ===
    final aesKeyParaAna = ana.privateKey.decrypt(payload.encryptedAesKeySender);
    final aesKey3 = enc.Key.fromBase64(aesKeyParaAna);
    final encrypter3 = enc.Encrypter(enc.AES(aesKey3, mode: enc.AESMode.cbc));
    final mensajeReleido = encrypter3.decrypt64(payload.cipherText, iv: iv2);

    expect(mensajeReleido, equals(mensajeOriginal));

    // Y la envoltura de Beto NO le sirve a Ana (llaves distintas a propósito).
    expect(
      () => ana.privateKey.decrypt(payload.encryptedAesKey),
      throwsA(anything),
    );
  });

  test('E2EE: un intruso con otra llave privada NO puede leer', () {
    final beto = RSAKeypair.fromRandom();
    final intruso = RSAKeypair.fromRandom();

    final aesKey = enc.Key.fromSecureRandom(32);
    final encryptedAesKey =
        RSAPublicKey.fromString(beto.publicKey.toString()).encrypt(aesKey.base64);

    // El intruso no puede abrir la llave AES con su propia privada.
    expect(
      () => intruso.privateKey.decrypt(encryptedAesKey),
      throwsA(anything),
    );
  });
}
