import 'package:dartz/dartz.dart';
import '../../../../core/enums.dart';
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
  Future<Either<Failure, UserEntity>> saveUserRole(UserRole role);
  Future<Either<Failure, UserEntity>> getCurrentUser();
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, void>> deleteAccount();
  Future<Either<Failure, UserEntity>> updateDisplayName(String fullName);
  Future<Either<Failure, void>> updatePassword(String newPassword);
}