import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/enums.dart';
import '../../../core/api_client.dart';
import '../../../core/error.dart';
import 'models.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? phone,
    String? businessName,
    String? specialty,
    String? location,
  });
  Future<UserModel> loginWithGoogle();
  Future<UserModel> saveUserRole(UserRole role);
  Future<UserModel> getCurrentUser();
  Future<void> deleteAccount();
  Future<UserModel> updateDisplayName(String fullName);
  Future<void> updatePassword(String newPassword);
  Future<UserModel> updateRole(UserRole role);
  Future<UserModel> uploadProfilePhoto({required List<int> bytes, required String filename});
  Future<void> logout();
}

/// Llama al API de Go (login por correo/contraseña + JWT). El token que
/// devuelve el backend se guarda con el resto del usuario en
/// SharedPreferences, así getCurrentUser() puede restaurar la sesión sin
/// otro round-trip de red.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _client;

  AuthRemoteDataSourceImpl(this._client);

  Future<void> _persist(UserModel user) async {
    if (user.token.isNotEmpty) {
      await _client.saveToken(user.token);
    }
    // Se reutiliza el mismo storage de shared_preferences que ApiClient ya
    // maneja para el token; el resto del perfil se guarda aparte, con su
    // propia clave, para no pisar la del token.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AuthRemoteDataSourceImpl._userKey, jsonEncode(user.toStorageJson()));
  }

  static const _userKey = 'vault_current_user';

  @override
  Future<UserModel> login(String email, String password) async {
    final body = await _client.post(
      '/auth/login',
      body: {'email': email, 'password': password},
      auth: false,
    );
    final user = UserModel.fromJson(body as Map<String, dynamic>);
    await _persist(user);
    return user;
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? phone,
    String? businessName,
    String? specialty,
    String? location,
  }) async {
    final body = await _client.post(
      '/users',
      body: {
        'name': fullName,
        'email': email,
        'password': password,
        'role': role.value,
      },
      auth: false,
    );
    final user = UserModel.fromJson(body as Map<String, dynamic>);
    await _persist(user);

    return user;
  }

  @override
  Future<UserModel> loginWithGoogle() async {
    throw const ServerFailure(
      'Inicio de sesión con Google no está disponible todavía.',
    );
  }

  @override
  Future<UserModel> saveUserRole(UserRole role) async {
    throw const ServerFailure(
      'Inicio de sesión con Google no está disponible todavía.',
    );
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);
    if (raw == null) {
      throw const ServerFailure('No hay sesión activa.');
    }
    return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> deleteAccount() async {
    final user = await getCurrentUser();
    await _client.delete('/users/${user.id}');
    await _clearSession();
  }

  @override
  Future<UserModel> updateDisplayName(String fullName) async {
    final current = await getCurrentUser();
    final body = await _client.put('/users/${current.id}', body: {
      'name': fullName,
      'avatar_url': current.avatarUrl,
      'role': current.role.value,
    });
    return _applyUpdate(current, body as Map<String, dynamic>);
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    throw const ServerFailure(
      'Cambiar la contraseña todavía no está disponible.',
    );
  }

  @override
  Future<UserModel> updateRole(UserRole role) async {
    final current = await getCurrentUser();
    final body = await _client.put('/users/${current.id}', body: {
      'name': current.fullName ?? '',
      'avatar_url': current.avatarUrl,
      'role': role.value,
    });
    return _applyUpdate(current, body as Map<String, dynamic>);
  }

  @override
  Future<UserModel> uploadProfilePhoto({
    required List<int> bytes,
    required String filename,
  }) async {
    final current = await getCurrentUser();
    final body = await _client.putMultipart(
      '/users/${current.id}/image',
      bytes: bytes,
      filename: filename,
      fieldName: 'image',
    );
    return _applyUpdate(current, body as Map<String, dynamic>);
  }

  /// Combina la respuesta del backend (que no repite el token) con la
  /// sesión actual, y persiste el resultado.
  Future<UserModel> _applyUpdate(UserModel current, Map<String, dynamic> body) async {
    final updated = UserModel(
      id: current.id,
      email: current.email,
      fullName: body['name'] as String? ?? current.fullName,
      role: UserRole.fromValue(body['role'] as String? ?? current.role.value),
      avatarUrl: body['avatar_url'] as String? ?? current.avatarUrl,
      token: current.token,
    );
    await _persist(updated);
    return updated;
  }

  Future<void> _clearSession() async {
    await _client.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  @override
  Future<void> logout() => _clearSession();
}
