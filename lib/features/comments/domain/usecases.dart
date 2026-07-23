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
      repository.addComment(target: params.target, text: params.text);
}

class AddCommentParams extends Equatable {
  final CommentsTarget target;
  final String text;

  const AddCommentParams({required this.target, required this.text});

  @override
  List<Object?> get props => [target, text];
}
