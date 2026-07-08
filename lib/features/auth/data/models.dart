import '../../../../core/enums.dart';
import '../domain/entities.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.fullName,
    super.role,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      id: uid,
      email: data['email'] as String? ?? '',
      fullName: data['fullName'] as String?,
      role: UserRole.fromValue(data['role'] as String? ?? 'general'),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'fullName': fullName ?? '',
      'role': role.value,
    };
  }
}