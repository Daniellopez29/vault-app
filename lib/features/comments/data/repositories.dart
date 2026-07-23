import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';
import 'datasources.dart';

class CommentsRepositoryImpl implements CommentsRepository {
  final CommentsRemoteDataSource remoteDataSource;

  CommentsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<CommentEntity>>> getComments(CommentsTarget target) =>
      _guard(() => remoteDataSource.getComments(target));

  @override
  Future<Either<Failure, List<CommentEntity>>> addComment({
    required CommentsTarget target,
    required String text,
  }) =>
      _guard(() => remoteDataSource.addComment(target: target, text: text));

  /// Centraliza el try/catch → Either para getComments/addComment.
  Future<Either<Failure, List<CommentEntity>>> _guard(
      Future<List<CommentEntity>> Function() action) async {
    try {
      final comments = await action();
      return Right(comments);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }
}