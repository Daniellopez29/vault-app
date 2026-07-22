import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import '../../home/domain/entities.dart';
import '../domain/repositories.dart';
import 'datasources.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesRemoteDataSource remoteDataSource;

  const FavoritesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<PostEntity>>> getSavedPosts() async {
    try {
      final posts = await remoteDataSource.getSavedPosts();
      return Right(posts);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeSavedPost(String postId) async {
    try {
      await remoteDataSource.removeSavedPost(postId);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }
}