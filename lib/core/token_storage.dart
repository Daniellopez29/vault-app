import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Almacén encriptado para el token de sesión (JWT) y la marca de tiempo de
/// la última interacción del usuario.
///
/// Antes usaba SharedPreferences, que guarda en texto plano. Con
/// flutter_secure_storage los valores quedan cifrados por debajo usando
/// Android Keystore (EncryptedSharedPreferences) / iOS Keychain -- por eso
/// no requiere ninguna llave propia, la maneja el sistema operativo.
///
/// La marca de tiempo (`lastActivity`) es la que usa
/// [AuthController.checkInactivityOnResume] para decidir si debe cerrar la
/// sesión aunque el Timer en memoria no haya llegado a dispararse (p. ej. si
/// el sistema operativo mató el proceso mientras la app estaba en segundo
/// plano).
class TokenStorage {
  static const _tokenKey = 'vault_auth_token';
  static const _lastActivityKey = 'vault_last_activity_ms';

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> save(String token) => _storage.write(key: _tokenKey, value: token);

  Future<String?> read() => _storage.read(key: _tokenKey);

  Future<void> clear() => _storage.delete(key: _tokenKey);

  /// Guarda el instante (epoch en milisegundos) de la última interacción.
  Future<void> saveLastActivity(DateTime time) => _storage.write(
    key: _lastActivityKey,
    value: time.millisecondsSinceEpoch.toString(),
  );

  /// Última interacción registrada, o null si nunca se guardó una (p. ej.
  /// primera vez que se abre la app, o ya se limpió al cerrar sesión).
  Future<DateTime?> readLastActivity() async {
    final raw = await _storage.read(key: _lastActivityKey);
    if (raw == null) return null;
    final ms = int.tryParse(raw);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> clearLastActivity() => _storage.delete(key: _lastActivityKey);
}