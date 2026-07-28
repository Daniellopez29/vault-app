import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';
import 'datasources.dart';

class ConnectRepositoryImpl implements ConnectRepository {
  final ConnectRemoteDataSource _remote;

  ConnectRepositoryImpl({required ConnectRemoteDataSource remote}) : _remote = remote;

  @override
  Future<Either<Failure, ConnectStatusEntity>> getStatus() async {
    try {
      final status = await _remote.getStatus();
      return Right(status);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Error al consultar tu estado de cobros: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> createOnboardingLink({
    required String email,
    required String refreshUrl,
    required String returnUrl,
  }) async {
    try {
      final url = await _remote.createOnboardingLink(
        email: email,
        refreshUrl: refreshUrl,
        returnUrl: returnUrl,
      );
      return Right(url);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Error al generar el link de registro: $e'));
    }
  }
}
