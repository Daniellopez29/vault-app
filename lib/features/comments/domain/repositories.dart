import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import 'entities.dart';

abstract class CommentsRepository {
  /// Comentarios de un post o artículo.
  Future<Either<Failure, List<CommentEntity>>> getComments(CommentsTarget target);

  /// Agrega un comentario y devuelve la lista actualizada del target.
  Future<Either<Failure, List<CommentEntity>>> addComment({
    required CommentsTarget target,
    required String text,
  });
}