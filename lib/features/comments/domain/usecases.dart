import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error.dart';
import 'entities.dart';
import 'repositories.dart';

class GetCommentsUseCase {
  final CommentsRepository repository;
  const GetCommentsUseCase(this.repository);

  Future<Either<Failure, List<CommentEntity>>> call(CommentsTarget target) =>
      repository.getComments(target);
}

class AddCommentUseCase {
  final CommentsRepository repository;
  const AddCommentUseCase(this.repository);

  Future<Either<Failure, List<CommentEntity>>> call(AddCommentParams params) =>
      repository.addComment(
        target: params.target,
        text: params.text,
        parentId: params.parentId,
      );
}

class AddCommentParams extends Equatable {
  final CommentsTarget target;
  final String text;
  final String? parentId;

  const AddCommentParams({
    required this.target,
    required this.text,
    this.parentId,
  });

  @override
  List<Object?> get props => [target, text, parentId];
}

class DeleteCommentUseCase {
  final CommentsRepository repository;
  const DeleteCommentUseCase(this.repository);

  Future<Either<Failure, List<CommentEntity>>> call(DeleteCommentParams params) =>
      repository.deleteComment(target: params.target, commentId: params.commentId);
}

class DeleteCommentParams extends Equatable {
  final CommentsTarget target;
  final String commentId;

  const DeleteCommentParams({required this.target, required this.commentId});

  @override
  List<Object?> get props => [target, commentId];
}