import '../../../../core/enums.dart';
import '../domain/entities.dart';

class UserModel extends UserEntity {
  final String token;

  const UserModel({
    required super.id,
    required super.email,
    super.fullName,
    super.role,
    super.avatarUrl,
    super.roles,
    super.isNewUser,
    this.token = '',
  });

  /// Respuesta de POST /api/v1/auth/login y POST /api/v1/users del API Go.
  /// Si `roles` viene vacía (backend viejo, o sesión guardada localmente
  /// antes de este cambio), cae a `[role]` para no dejar la cuenta sin
  /// ningún rol acumulado.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    final role = UserRole.fromValue(json['role'] as String? ?? 'usuario');
    final rolesJson = json['roles'] as List<dynamic>? ?? const [];
    final roles = rolesJson.map((r) => UserRole.fromValue(r as String)).toList();

    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      fullName: json['name'] as String?,
      role: role,
      avatarUrl: json['avatar_url'] as String? ?? '',
      roles: roles.isEmpty ? [role] : roles,
      isNewUser: json['is_new_user'] as bool? ?? false,
      token: json['token'] as String? ?? '',
    );
  }

  Map<String, dynamic> toStorageJson() {
    return {
      'id': id,
      'email': email,
      'name': fullName,
      'role': role.value,
      'avatar_url': avatarUrl,
      'roles': roles.map((r) => r.value).toList(),
      'token': token,
    };
  }
}
