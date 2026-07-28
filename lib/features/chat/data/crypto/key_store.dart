import 'package:crypton/crypton.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Guarda y recupera el par de claves RSA del usuario, en un slot propio
/// POR CUENTA (`vault_rsa_..._<userId>`).
///
/// La clave PRIVADA se guarda en flutter_secure_storage, que usa el
/// almacenamiento seguro del sistema (Keystore en Android). Nunca se sube
/// a ningún servidor ni se expone fuera del dispositivo.
///
/// Usa crypton para generar el par y convertir claves a/desde texto, sin
/// manipular ASN.1/PEM a mano. crypton se apoya en pointycastle por debajo.
///
/// Versión previa de este archivo guardaba UN solo par en un slot fijo por
/// DISPOSITIVO (no por cuenta): al detectar que la cuenta logueada no era la
/// "dueña" registrada, generaba un par nuevo pisando el anterior. Eso perdía
/// para siempre la privada de cualquier cuenta que no fuera la última en usar
/// el teléfono -- los mensajes cifrados con esa llave quedan indescifrables
/// (no hay backup posible, la privada nunca salió del dispositivo). Los
/// campos `_legacy*` de abajo son solo para migrar, una única vez, la llave
/// de quien SÍ seguía siendo el dueño registrado al momento de este fix.
class KeyStore {
  static const _legacyPrivateKeyName = 'vault_rsa_private_key';
  static const _legacyPublicKeyName = 'vault_rsa_public_key';
  static const _legacyOwnerIdName = 'vault_rsa_key_owner_id';

  final FlutterSecureStorage _storage;

  KeyStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  String _privateKeyName(String userId) => 'vault_rsa_private_key_$userId';
  String _publicKeyName(String userId) => 'vault_rsa_public_key_$userId';

  /// ¿Ya existe un par de claves guardado para [userId]?
  Future<bool> hasKeyPair(String userId) async {
    await _migrateLegacyKeyIfOwnedBy(userId);
    final priv = await _storage.read(key: _privateKeyName(userId));
    return priv != null;
  }

  /// Genera un par nuevo para [userId] y lo guarda. Devuelve la clave
  /// pública en texto, lista para subirse al servidor.
  Future<String> generateAndStore(String userId) async {
    final keypair = RSAKeypair.fromRandom();
    final privateStr = keypair.privateKey.toString();
    final publicStr = keypair.publicKey.toString();

    await _storage.write(key: _privateKeyName(userId), value: privateStr);
    await _storage.write(key: _publicKeyName(userId), value: publicStr);
    return publicStr;
  }

  /// Recupera la clave privada de [userId] como objeto usable, o null si no
  /// existe.
  Future<RSAPrivateKey?> readPrivateKey(String userId) async {
    await _migrateLegacyKeyIfOwnedBy(userId);
    final str = await _storage.read(key: _privateKeyName(userId));
    if (str == null) return null;
    return RSAPrivateKey.fromString(str);
  }

  /// Recupera la clave pública de [userId] en texto, o null si no existe.
  Future<String?> readPublicKey(String userId) async {
    await _migrateLegacyKeyIfOwnedBy(userId);
    return _storage.read(key: _publicKeyName(userId));
  }

  /// Copia, una sola vez, el par legado al slot propio de [userId] -- pero
  /// solo si [userId] sigue siendo el dueño que quedó registrado la última
  /// vez que se usó el slot único. Cualquier otra cuenta ya perdió esa
  /// llave antes de este fix; no hay nada que migrar para ella.
  Future<void> _migrateLegacyKeyIfOwnedBy(String userId) async {
    final alreadyMigrated = await _storage.read(key: _privateKeyName(userId));
    if (alreadyMigrated != null) return;

    final legacyOwner = await _storage.read(key: _legacyOwnerIdName);
    if (legacyOwner != userId) return;

    final legacyPrivate = await _storage.read(key: _legacyPrivateKeyName);
    final legacyPublic = await _storage.read(key: _legacyPublicKeyName);
    if (legacyPrivate == null || legacyPublic == null) return;

    await _storage.write(key: _privateKeyName(userId), value: legacyPrivate);
    await _storage.write(key: _publicKeyName(userId), value: legacyPublic);
  }
}
