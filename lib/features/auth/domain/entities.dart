import 'package:equatable/equatable.dart';
import '../../../../core/enums.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? fullName;
  final UserRole role;

  const UserEntity({
    required this.id,
    required this.email,
    this.fullName,
    this.role = UserRole.general,
  });

  @override
  List<Object?> get props => [id, email, fullName, role];
}