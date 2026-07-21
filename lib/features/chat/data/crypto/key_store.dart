import 'package:crypton/crypton.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Guarda y recupera el par de claves RSA del usuario.
///
/// La clave PRIVADA se guarda en flutter_secure_storage, que usa el
/// almacenamiento seguro del sistema (Keystore en Android). Nunca se sube
/// a ningún servidor ni se expone fuera del dispositivo.
///
/// Usa crypton para generar el par y convertir claves a/desde texto, sin
/// manipular ASN.1/PEM a mano. crypton se apoya en pointycastle por debajo.
class KeyStore {
  static const _privateKeyName = 'vault_rsa_private_key';
  static const _publicKeyName = 'vault_rsa_public_key';

  final FlutterSecureStorage _storage;

  KeyStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  /// ¿Ya existe un par de claves guardado?
  Future<bool> hasKeyPair() async {
    final priv = await _storage.read(key: _privateKeyName);
    return priv != null;
  }

  /// Genera un par nuevo y lo guarda. Devuelve la clave pública en texto,
  /// lista para subirse al servidor.
  Future<String> generateAndStore() async {
    final keypair = RSAKeypair.fromRandom();
    final privateStr = keypair.privateKey.toString();
    final publicStr = keypair.publicKey.toString();

    await _storage.write(key: _privateKeyName, value: privateStr);
    await _storage.write(key: _publicKeyName, value: publicStr);
    return publicStr;
  }

  /// Recupera la clave privada como objeto usable, o null si no existe.
  Future<RSAPrivateKey?> readPrivateKey() async {
    final str = await _storage.read(key: _privateKeyName);
    if (str == null) return null;
    return RSAPrivateKey.fromString(str);
  }

  /// Recupera la clave pública propia en texto, o null si no existe.
  Future<String?> readPublicKey() async {
    return _storage.read(key: _publicKeyName);
  }
}
