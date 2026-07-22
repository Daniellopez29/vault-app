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
    this.token = '',
  });

  /// Respuesta de POST /api/v1/auth/login y POST /api/v1/users del API Go.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      fullName: json['name'] as String?,
      role: UserRole.fromValue(json['role'] as String? ?? 'usuario'),
      avatarUrl: json['avatar_url'] as String? ?? '',
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
      'token': token,
    };
  }
}
