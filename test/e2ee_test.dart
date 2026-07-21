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
    // Beto genera su par. Solo comparte la pública.
    final beto = RSAKeypair.fromRandom();
    final betoPublicKey = beto.publicKey.toString();

    const mensajeOriginal = 'Hola Beto, este mensaje es secreto 🔒';

    // === ANA cifra ===
    final aesKey = enc.Key.fromSecureRandom(32);
    final iv = enc.IV.fromSecureRandom(16);
    final encrypter = enc.Encrypter(enc.AES(aesKey, mode: enc.AESMode.cbc));
    final cipherText = encrypter.encrypt(mensajeOriginal, iv: iv).base64;
    final encryptedAesKey =
        RSAPublicKey.fromString(betoPublicKey).encrypt(aesKey.base64);

    // Lo que viaja por la red = la entidad del dominio.
    final payload = EncryptedMessageEntity(
      cipherText: cipherText,
      encryptedAesKey: encryptedAesKey,
      iv: iv.base64,
    );

    print('=== Lo que vería el servidor (ilegible) ===');
    print('cipherText: ${payload.cipherText}');
    print('encryptedAesKey: ${payload.encryptedAesKey.substring(0, 40)}...');
    print('');

    // El cifrado no revela el mensaje.
    expect(payload.cipherText.contains('Beto'), isFalse);
    expect(payload.cipherText.contains('secreto'), isFalse);

    // === BETO descifra ===
    final aesKeyRecuperada = beto.privateKey.decrypt(payload.encryptedAesKey);
    final aesKey2 = enc.Key.fromBase64(aesKeyRecuperada);
    final iv2 = enc.IV.fromBase64(payload.iv);
    final encrypter2 = enc.Encrypter(enc.AES(aesKey2, mode: enc.AESMode.cbc));
    final mensajeDescifrado = encrypter2.decrypt64(payload.cipherText, iv: iv2);

    print('=== Lo que lee Beto (con su llave privada) ===');
    print('Mensaje: $mensajeDescifrado');

    expect(mensajeDescifrado, equals(mensajeOriginal));
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
