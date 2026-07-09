import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import '../../home/domain/entities.dart';
import '../domain/repositories.dart';
import 'datasources.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesLocalDataSource localDataSource;

  const FavoritesRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<PostEntity>>> getSavedPosts() async {
    try {
      final posts = await localDataSource.getSavedPosts();
      return Right(posts);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeSavedPost(String postId) async {
    try {
      await localDataSource.removeSavedPost(postId);
      return const Right(null);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }
}