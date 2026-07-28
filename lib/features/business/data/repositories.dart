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
        userId: business.userId,
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
      // Ver profile/data/repositories.dart: sin este .of(...), la lista
      // conserva el tipo reificado List<BusinessModel> y cualquier
      // firstWhere(orElse: ...) sobre ella puede tronar en tiempo de
      // ejecución.
      return Right(List<BusinessEntity>.of(businesses));
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

  @override
  Future<Either<Failure, BusinessEntity>> deletePhoto(String id, String photoId) async {
    try {
      final updated = await remoteDataSource.deletePhoto(id, photoId);
      return Right(updated);
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return const Left(ServerFailure('Error al eliminar la foto.'));
    }
  }

  @override
  Future<Either<Failure, List<BusinessServiceEntity>>> getServices(String businessId) async {
    try {
      final services = await remoteDataSource.getServices(businessId);
      return Right(List<BusinessServiceEntity>.of(services));
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return const Left(ServerFailure('Error al cargar los servicios.'));
    }
  }

  @override
  Future<Either<Failure, BusinessServiceEntity>> createService(
    String businessId, {
    required String title,
    required String description,
    required double price,
  }) async {
    try {
      final created = await remoteDataSource.createService(
        businessId,
        title: title,
        description: description,
        price: price,
      );
      return Right(created);
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return const Left(ServerFailure('Error al publicar el servicio.'));
    }
  }

  @override
  Future<Either<Failure, BusinessServiceEntity>> updateService(
    String businessId,
    String serviceId, {
    required String title,
    required String description,
    required double price,
  }) async {
    try {
      final updated = await remoteDataSource.updateService(
        businessId,
        serviceId,
        title: title,
        description: description,
        price: price,
      );
      return Right(updated);
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return const Left(ServerFailure('Error al actualizar el servicio.'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteService(String businessId, String serviceId) async {
    try {
      await remoteDataSource.deleteService(businessId, serviceId);
      return const Right(null);
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return const Left(ServerFailure('Error al eliminar el servicio.'));
    }
  }
}
