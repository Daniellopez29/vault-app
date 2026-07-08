import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error.dart';
import 'entities.dart';
import 'repositories.dart';

class GetCommentsUseCase {
  final CommentsRepository repository;
  const GetCommentsUseCase(this.repository);

  Future<Either<Failure, List<CommentEntity>>> call(String targetId) =>
      repository.getComments(targetId);
}

class AddCommentUseCase {
  final CommentsRepository repository;
  const AddCommentUseCase(this.repository);

  Future<Either<Failure, List<CommentEntity>>> call(AddCommentParams params) =>
      repository.addComment(targetId: params.targetId, text: params.text);
}

class ToggleCommentLikeUseCase {
  final CommentsRepository repository;
  const ToggleCommentLikeUseCase(this.repository);

  Future<Either<Failure, List<CommentEntity>>> call(
      ToggleCommentLikeParams params) =>
      repository.toggleLike(
        targetId: params.targetId,
        commentId: params.commentId,
      );
}

class AddCommentParams extends Equatable {
  final String targetId;
  final String text;

  const AddCommentParams({required this.targetId, required this.text});

  @override
  List<Object?> get props => [targetId, text];
}

class ToggleCommentLikeParams extends Equatable {
  final String targetId;
  final String commentId;

  const ToggleCommentLikeParams({
    required this.targetId,
    required this.commentId,
  });

  @override
  List<Object?> get props => [targetId, commentId];
}