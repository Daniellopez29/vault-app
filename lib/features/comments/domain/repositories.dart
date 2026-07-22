import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import 'entities.dart';

abstract class CommentsRepository {
  /// Comentarios de un post o artículo (identificado por targetId).
  Future<Either<Failure, List<CommentEntity>>> getComments(String targetId);

  /// Agrega un comentario y devuelve la lista actualizada del target.
  Future<Either<Failure, List<CommentEntity>>> addComment({
    required String targetId,
    required String text,
  });
}