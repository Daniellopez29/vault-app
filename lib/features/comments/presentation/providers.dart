import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../data/datasources.dart';
import '../data/repositories.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';
import '../domain/usecases.dart';

final commentsRepositoryProvider = Provider<CommentsRepository>((ref) {
  return CommentsRepositoryImpl(
    remoteDataSource: CommentsRemoteDataSourceImpl(ref.read(apiClientProvider)),
  );
});

final getCommentsUseCaseProvider = Provider<GetCommentsUseCase>((ref) {
  return GetCommentsUseCase(ref.read(commentsRepositoryProvider));
});

final addCommentUseCaseProvider = Provider<AddCommentUseCase>((ref) {
  return AddCommentUseCase(ref.read(commentsRepositoryProvider));
});

final deleteCommentUseCaseProvider = Provider<DeleteCommentUseCase>((ref) {
  return DeleteCommentUseCase(ref.read(commentsRepositoryProvider));
});

enum CommentsStatus { initial, loading, loaded, error }

class CommentsState {
  final CommentsStatus status;
  final List<CommentEntity> comments;
  final String? errorMessage;

  const CommentsState({
    this.status = CommentsStatus.initial,
    this.comments = const [],
    this.errorMessage,
  });

  int get count => comments.length;

  CommentsState copyWith({
    CommentsStatus? status,
    List<CommentEntity>? comments,
    String? errorMessage,
  }) {
    return CommentsState(
      status: status ?? this.status,
      comments: comments ?? this.comments,
      errorMessage: errorMessage,
    );
  }
}

final commentsControllerProvider = StateNotifierProvider.family<CommentsController, CommentsState, CommentsTarget>((ref, target) {
  return CommentsController(
    target: target,
    getComments: ref.read(getCommentsUseCaseProvider),
    addComment: ref.read(addCommentUseCaseProvider),
    deleteComment: ref.read(deleteCommentUseCaseProvider),
  );
});

class CommentsController extends StateNotifier<CommentsState> {
  final CommentsTarget _target;
  final GetCommentsUseCase _getComments;
  final AddCommentUseCase _addComment;
  final DeleteCommentUseCase _deleteComment;

  CommentsController({
    required CommentsTarget target,
    required GetCommentsUseCase getComments,
    required AddCommentUseCase addComment,
    required DeleteCommentUseCase deleteComment,
  })  : _target = target,
        _getComments = getComments,
        _addComment = addComment,
        _deleteComment = deleteComment,
        super(const CommentsState()) {
    loadComments();
  }

  Future<void> loadComments() async {
    state = state.copyWith(status: CommentsStatus.loading);
    final result = await _getComments(_target);
    _apply(result);
  }

  Future<void> addComment(String text, {String? parentId}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final result = await _addComment(
      AddCommentParams(target: _target, text: trimmed, parentId: parentId),
    );
    _apply(result);
  }

  Future<void> deleteComment(String commentId) async {
    final optimistic = state.comments.where((c) => c.id != commentId).toList();
    state = state.copyWith(comments: optimistic);
    final result = await _deleteComment(
      DeleteCommentParams(target: _target, commentId: commentId),
    );
    _apply(result);
  }

  void toggleLike(String commentId) {
    final optimistic = state.comments.map((c) {
      if (c.id != commentId) return c;
      return c.copyWith(
        isLiked: !c.isLiked,
        likesCount: c.isLiked ? c.likesCount - 1 : c.likesCount + 1,
      );
    }).toList();
    state = state.copyWith(comments: optimistic);
  }

  void _apply(dynamic result) {
    result.fold(
      (failure) => state = state.copyWith(
        status: CommentsStatus.error,
        errorMessage: failure.message,
      ),
      (comments) => state = state.copyWith(
        status: CommentsStatus.loaded,
        comments: comments as List<CommentEntity>,
      ),
    );
  }
}