import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/error.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';
import 'datasources.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  const AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      await remoteDataSource.login(email, password);
      final user = FirebaseAuth.instance.currentUser;
      return Right(UserEntity(
        id: user?.uid ?? '',
        email: user?.email ?? email,
        fullName: user?.displayName,
      ));
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      await remoteDataSource.register(email, password, fullName);
      final user = FirebaseAuth.instance.currentUser;
      return Right(UserEntity(
        id: user?.uid ?? '',
        email: user?.email ?? email,
        fullName: user?.displayName ?? fullName,
      ));
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> loginWithGoogle() async {
    try {
      await remoteDataSource.loginWithGoogle();
      final user = FirebaseAuth.instance.currentUser;
      return Right(UserEntity(
        id: user?.uid ?? '',
        email: user?.email ?? '',
        fullName: user?.displayName,
      ));
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Error al cerrar sesión.'));
    }
  }
}