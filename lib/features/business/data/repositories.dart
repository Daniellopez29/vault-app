import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';
import 'datasources.dart';
import 'models.dart';

class BusinessRepositoryImpl implements BusinessRepository {
  final BusinessRemoteDataSource remoteDataSource;

  BusinessRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, BusinessEntity?>> getMyBusiness() async {
    try {
      final business = await remoteDataSource.getMyBusiness();
      return Right(business);
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return const Left(ServerFailure('Error al cargar tu negocio.'));
    }
  }

  @override
  Future<Either<Failure, BusinessEntity>> updateBusiness(BusinessEntity business) async {
    try {
      final model = BusinessModel(
        id: business.id,
        name: business.name,
        type: business.type,
        description: business.description,
        location: business.location,
        isVerified: business.isVerified,
      );
      final updated = await remoteDataSource.updateBusiness(business.id, model);
      return Right(updated);
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return const Left(ServerFailure('Error al actualizar tu negocio.'));
    }
  }
}
