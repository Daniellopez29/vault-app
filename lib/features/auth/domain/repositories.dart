import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import 'entities.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required String fullName,
  });

  Future<Either<Failure, UserEntity>> loginWithGoogle();
  Future<Either<Failure, void>> logout();
}