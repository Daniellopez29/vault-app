import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
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
      );
}

class RegisterParams extends Equatable {
  final String email;
  final String password;
  final String fullName;
  const RegisterParams({
    required this.email,
    required this.password,
    required this.fullName,
  });

  @override
  List<Object?> get props => [email, password, fullName];
}

class LoginWithGoogleUseCase {
  final AuthRepository repository;
  const LoginWithGoogleUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call() => repository.loginWithGoogle();
}