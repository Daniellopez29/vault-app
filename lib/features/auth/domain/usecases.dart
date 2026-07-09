import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/enums.dart';
import '../../../core/error.dart';
import '../../../core/usecase.dart';
import 'entities.dart';
import 'repositories.dart';


class LoginUseCase implements UseCase<UserEntity, LoginParams> {
  final AuthRepository repository;
  const LoginUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(LoginParams params) =>
      repository.login(email: params.email, password: params.password);
}

class UpdateDisplayNameUseCase {
  final AuthRepository repository;
  const UpdateDisplayNameUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(String fullName) =>
      repository.updateDisplayName(fullName);
}

class LoginParams extends Equatable {
  final String email;
  final String password;
  const LoginParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class RegisterUseCase implements UseCase<UserEntity, RegisterParams> {
  final AuthRepository repository;
  const RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(RegisterParams params) =>
      repository.register(
        email: params.email,
        password: params.password,
        fullName: params.fullName,
        role: params.role,
        phone: params.phone,
        businessName: params.businessName,
        specialty: params.specialty,
        location: params.location,
      );
}

class RegisterParams extends Equatable {
  final String email;
  final String password;
  final String fullName;
  final UserRole role;

  // Campos opcionales por rol (Vendedor, Restaurador, Servicio).
  // Se capturan en la UI; su persistencia llega con Supabase.
  final String? phone;
  final String? businessName;
  final String? specialty;
  final String? location;

  const RegisterParams({
    required this.email,
    required this.password,
    required this.fullName,
    required this.role,
    this.phone,
    this.businessName,
    this.specialty,
    this.location,
  });

  @override
  List<Object?> get props => [
    email,
    password,
    fullName,
    role,
    phone,
    businessName,
    specialty,
    location,
  ];
}

class LoginWithGoogleUseCase {
  final AuthRepository repository;
  const LoginWithGoogleUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call() => repository.loginWithGoogle();
}

class SaveUserRoleUseCase {
  final AuthRepository repository;
  const SaveUserRoleUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(UserRole role) =>
      repository.saveUserRole(role);
}

class GetCurrentUserUseCase {
  final AuthRepository repository;
  const GetCurrentUserUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call() => repository.getCurrentUser();
}

class DeleteAccountUseCase {
  final AuthRepository repository;
  const DeleteAccountUseCase(this.repository);

  Future<Either<Failure, void>> call() => repository.deleteAccount();
}

class LogoutUseCase {
  final AuthRepository repository;
  const LogoutUseCase(this.repository);

  Future<Either<Failure, void>> call() => repository.logout();
}

class UpdatePasswordUseCase {
  final AuthRepository repository;
  const UpdatePasswordUseCase(this.repository);

  Future<Either<Failure, void>> call(String newPassword) =>
      repository.updatePassword(newPassword);
}