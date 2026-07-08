import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';
import 'datasources.dart';

class CommentsRepositoryImpl implements CommentsRepository {
  final CommentsRemoteDataSource remoteDataSource;

  /// Provee el nombre del autor actual (viene de auth, resuelto en la capa
  /// de providers). Así el dominio no conoce nada de auth.
  final String Function() currentAuthorName;

  CommentsRepositoryImpl({
    required this.remoteDataSource,
    required this.currentAuthorName,
  });

  @override
  Future<Either<Failure, List<CommentEntity>>> getComments(String targetId) =>
      _guard(() => remoteDataSource.getComments(targetId));

  @override
  Future<Either<Failure, List<CommentEntity>>> addComment({
    required String targetId,
    required String text,
  }) =>
      _guard(() => remoteDataSource.addComment(
        targetId: targetId,
        text: text,
        authorName: currentAuthorName(),
      ));

  @override
  Future<Either<Failure, List<CommentEntity>>> toggleLike({
    required String targetId,
    required String commentId,
  }) =>
      _guard(() => remoteDataSource.toggleLike(
        targetId: targetId,
        commentId: commentId,
      ));

  /// Centraliza el try/catch → Either para las tres operaciones.
  Future<Either<Failure, List<CommentEntity>>> _guard(
      Future<List<CommentEntity>> Function() action) async {
    try {
      final comments = await action();
      return Right(comments);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }
}