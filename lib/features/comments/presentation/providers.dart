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

/// Un controller por target (post o artículo). El `.family` recibe el
/// CommentsTarget completo (id + tipo), así el Feed y el Marketplace usan
/// la misma lógica apuntando a recursos distintos del backend.
final commentsControllerProvider = StateNotifierProvider.family<
    CommentsController, CommentsState, CommentsTarget>((ref, target) {
  return CommentsController(
    target: target,
    getComments: ref.read(getCommentsUseCaseProvider),
    addComment: ref.read(addCommentUseCaseProvider),
  );
});

class CommentsController extends StateNotifier<CommentsState> {
  final CommentsTarget _target;
  final GetCommentsUseCase _getComments;
  final AddCommentUseCase _addComment;

  CommentsController({
    required CommentsTarget target,
    required this._getComments,
    required this._addComment,
  })  : _target = target,
        super(const CommentsState()) {
    loadComments();
  }

  Future<void> loadComments() async {
    state = state.copyWith(status: CommentsStatus.loading);
    final result = await _getComments(_target);
    _apply(result);
  }

  Future<void> addComment(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final result = await _addComment(
      AddCommentParams(target: _target, text: trimmed),
    );
    _apply(result);
  }

  /// El backend no tiene tabla de likes de comentarios: esto es puramente
  /// estado local de la sesión, no se llama a la red ni se persiste.
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

  /// Aplica el resultado de un caso de uso al estado, en un solo lugar.
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
