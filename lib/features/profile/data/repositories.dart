import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';
import 'datasources.dart';
import 'restorer_local_datasource.dart';
import 'models.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  /// TEMPORAL: el backend aun no persiste el perfil de especialista, asi que
  /// se guarda en el dispositivo. Cuando exista el endpoint, se elimina.
  final RestorerProfileLocalDataSource localDataSource;

  const ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<AssetEntity>>> getUserAssets() async {
    try {
      final assets = await remoteDataSource.getUserAssets();
      return Right(assets);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addAsset(AssetEntity asset) async {
    try {
      await remoteDataSource.addAsset(AssetModel.fromEntity(asset));
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateAsset(AssetEntity asset) async {
    try {
      await remoteDataSource.updateAsset(AssetModel.fromEntity(asset));
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAsset(String assetId) async {
    try {
      await remoteDataSource.deleteAsset(assetId);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, RestorerProfileEntity?>> getRestorerProfile(
      String userId) async {
    try {
      final local = await localDataSource.read(userId);
      if (local != null) return Right(local);
      final profile = await remoteDataSource.getRestorerProfile(userId);
      return Right(profile);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveRestorerProfile(
      RestorerProfileEntity profile) async {
    try {
      final model = RestorerProfileModel(
        userId: profile.userId,
        bio: profile.bio,
        specialties: profile.specialties,
        services: profile.services
            .map((s) => RestorerServiceModel(
          id: s.id,
          title: s.title,
          description: s.description,
          price: s.price,
        ))
            .toList(),
        rating: profile.rating,
        reviewsCount: profile.reviewsCount,
      );
      await localDataSource.write(model);
      await remoteDataSource.saveRestorerProfile(model);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> registerBusiness({
    required String name,
    required String type,
    required String description,
    required String location,
  }) async {
    try {
      await remoteDataSource.registerBusiness(
        name: name,
        type: type,
        description: description,
        location: location,
      );
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<RestorerProfileEntity>>>
      getAllRestorerProfiles() async {
    try {
      // TEMPORAL: se leen los perfiles guardados en el dispositivo. Cuando
      // el backend exponga el endpoint, esto pasa a remoteDataSource.
      final profiles = await localDataSource.readAll();
      // Solo tiene sentido listar a quienes publicaron algo.
      final withServices =
          profiles.where((p) => p.services.isNotEmpty).toList();
      return Right(withServices);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return const Left(ServerFailure('Error al cargar los servicios.'));
    }
  }
}


