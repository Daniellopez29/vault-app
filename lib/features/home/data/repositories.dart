import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';
import 'datasources.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<PostEntity>>> getFeedPosts() async {
    try {
      final posts = await remoteDataSource.getFeedPosts();
      return Right(posts);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ' + e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleLike(String postId, bool currentlyLiked) async {
    try {
      await remoteDataSource.toggleLike(postId, currentlyLiked);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ' + e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleSave(String postId, bool currentlySaved) async {
    try {
      await remoteDataSource.toggleSave(postId, currentlySaved);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ' + e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createPost({
    required String content,
    required List<PostImageUpload> images,
  }) async {
    try {
      await remoteDataSource.createPost(content: content, images: images);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ' + e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePost(String postId) async {
    try {
      await remoteDataSource.deletePost(postId);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ' + e.toString()));
    }
  }
}
