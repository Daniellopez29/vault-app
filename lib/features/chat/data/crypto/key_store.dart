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
  // Id del usuario dueño del par guardado -- este storage es único por
  // dispositivo, no por cuenta, así que si dos usuarios distintos inician
  // sesión en el mismo teléfono hay que notar el cambio de dueño y generar
  // un par nuevo en vez de que la segunda cuenta reuse (y re-registre en el
  // servidor) la llave de la primera.
  static const _ownerIdName = 'vault_rsa_key_owner_id';

  final FlutterSecureStorage _storage;

  KeyStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  /// ¿Ya existe un par de claves guardado?
  Future<bool> hasKeyPair() async {
    final priv = await _storage.read(key: _privateKeyName);
    return priv != null;
  }

  /// Id del usuario al que pertenece el par guardado actualmente, o null si
  /// no hay ninguno o se guardó antes de este control (versión previa).
  Future<String?> readOwnerId() async => _storage.read(key: _ownerIdName);

  Future<void> setOwnerId(String userId) async {
    await _storage.write(key: _ownerIdName, value: userId);
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
