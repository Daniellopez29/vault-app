import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import 'entities.dart';

abstract class CommentsRepository {
  Future<Either<Failure, List<CommentEntity>>> getComments(CommentsTarget target);

  Future<Either<Failure, List<CommentEntity>>> addComment({
    required CommentsTarget target,
    required String text,
    String? parentId,
  });

  Future<Either<Failure, List<CommentEntity>>> deleteComment({
    required CommentsTarget target,
    required String commentId,
  });
}