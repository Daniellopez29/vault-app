import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';
import 'datasources.dart';

class AdRepositoryImpl implements AdRepository {
  final AdRemoteDataSource _remote;

  AdRepositoryImpl({required AdRemoteDataSource remote}) : _remote = remote;

  @override
  Future<Either<Failure, List<AdEntity>>> getActiveAds(String section) async {
    try {
      final ads = await _remote.getActiveAds(section);
      return Right(ads);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Error al cargar los anuncios: $e'));
    }
  }

  @override
  Future<Either<Failure, AdEntity>> createAd({
    required String title,
    required String description,
    required String imageUrl,
    required String targetSection,
    required String targetId,
  }) async {
    try {
      final ad = await _remote.createAd(
        title: title,
        description: description,
        imageUrl: imageUrl,
        targetSection: targetSection,
        targetId: targetId,
      );
      return Right(ad);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Error al crear el anuncio: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAd(String id) async {
    try {
      await _remote.deleteAd(id);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Error al eliminar el anuncio: $e'));
    }
  }
}
