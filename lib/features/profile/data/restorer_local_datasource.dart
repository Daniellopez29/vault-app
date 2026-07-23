import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

/// Guarda el perfil de especialista (bio, especialidades, servicios) en el
/// dispositivo.
///
/// TEMPORAL: el backend todavia no expone endpoints para persistir ni
/// consultar este perfil (ver ProfileRemoteDataSourceImpl, cuyos metodos
/// estan vacios). Cuando existan, el repositorio deja de usar esta clase.
abstract class RestorerProfileLocalDataSource {
  Future<RestorerProfileModel?> read(String userId);

  Future<void> write(RestorerProfileModel profile);

  /// Todos los perfiles guardados, para el directorio publico de servicios.
  Future<List<RestorerProfileModel>> readAll();
}

class RestorerProfileLocalDataSourceImpl
    implements RestorerProfileLocalDataSource {
  static const _keyPrefix = 'vault_restorer_profile_';

  @override
  Future<RestorerProfileModel?> read(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_keyPrefix$userId');
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return RestorerProfileModel.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> write(RestorerProfileModel profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_keyPrefix${profile.userId}',
      jsonEncode(profile.toJson()),
    );
  }

  @override
  Future<List<RestorerProfileModel>> readAll() async {
    final prefs = await SharedPreferences.getInstance();
    final profiles = <RestorerProfileModel>[];
    for (final key in prefs.getKeys()) {
      if (!key.startsWith(_keyPrefix)) continue;
      final raw = prefs.getString(key);
      if (raw == null) continue;
      try {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        profiles.add(RestorerProfileModel.fromJson(json));
      } catch (_) {
        continue;
      }
    }
    return profiles;
  }
}
