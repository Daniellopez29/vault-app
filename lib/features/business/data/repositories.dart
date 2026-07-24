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
        types: business.types,
        description: business.description,
        location: business.location,
        isVerified: business.isVerified,
        specialties: business.specialties,
        photos: business.photos,
      );
      final updated = await remoteDataSource.updateBusiness(business.id, model);
      return Right(updated);
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return const Left(ServerFailure('Error al actualizar tu negocio.'));
    }
  }

  @override
  Future<Either<Failure, List<BusinessEntity>>> getAllBusinesses() async {
    try {
      final businesses = await remoteDataSource.getAllBusinesses();
      return Right(businesses);
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return const Left(ServerFailure('Error al cargar los negocios.'));
    }
  }

  @override
  Future<Either<Failure, BusinessEntity>> uploadPhoto(
    String id, {
    required List<int> bytes,
    required String filename,
  }) async {
    try {
      final updated = await remoteDataSource.uploadPhoto(id, bytes: bytes, filename: filename);
      return Right(updated);
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return const Left(ServerFailure('Error al subir la foto.'));
    }
  }
}
