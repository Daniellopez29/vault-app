import 'package:equatable/equatable.dart';
import '../../../../core/enums.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? fullName;
  final UserRole role;
  final String avatarUrl;

  /// Historico acumulado de roles que la cuenta ha adquirido (nunca se
  /// quita nada, solo se agrega) -- a diferencia de [role], que es el mas
  /// reciente/principal.
  final List<UserRole> roles;

  const UserEntity({
    required this.id,
    required this.email,
    this.fullName,
    this.role = UserRole.user,
    this.avatarUrl = '',
    this.roles = const [],
  });

  @override
  List<Object?> get props => [id, email, fullName, role, avatarUrl, roles];
}