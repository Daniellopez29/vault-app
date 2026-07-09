import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/providers.dart';
import '../data/datasources.dart';
import '../data/repositories.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';
import '../domain/usecases.dart';

final commentsRepositoryProvider = Provider<CommentsRepository>((ref) {
  return CommentsRepositoryImpl(
    remoteDataSource: CommentsRemoteDataSourceImpl(),
    // El nombre del autor sale de auth; aquí se resuelve el enganche.
    currentAuthorName: () =>
    ref.read(authControllerProvider).user?.fullName ?? 'Tú',
  );
});

final getCommentsUseCaseProvider = Provider<GetCommentsUseCase>((ref) {
  return GetCommentsUseCase(ref.read(commentsRepositoryProvider));
});

final addCommentUseCaseProvider = Provider<AddCommentUseCase>((ref) {
  return AddCommentUseCase(ref.read(commentsRepositoryProvider));
});

final toggleCommentLikeUseCaseProvider =
Provider<ToggleCommentLikeUseCase>((ref) {
  return ToggleCommentLikeUseCase(ref.read(commentsRepositoryProvider));
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

/// Un controller por target (post o artículo). El `.family` recibe el targetId,
/// así el Feed y el Marketplace usan la misma lógica apuntando a cosas distintas.
final commentsControllerProvider = StateNotifierProvider.family<
    CommentsController, CommentsState, String>((ref, targetId) {
  return CommentsController(
    targetId: targetId,
    getComments: ref.read(getCommentsUseCaseProvider),
    addComment: ref.read(addCommentUseCaseProvider),
    toggleLike: ref.read(toggleCommentLikeUseCaseProvider),
  );
});

class CommentsController extends StateNotifier<CommentsState> {
  final String _targetId;
  final GetCommentsUseCase _getComments;
  final AddCommentUseCase _addComment;
  final ToggleCommentLikeUseCase _toggleLike;

  CommentsController({
    required this._targetId,
    required GetCommentsUseCase getComments,
    required this._addComment,
    required this._toggleLike,
  })  : _getComments = getComments,
        super(const CommentsState()) {
    loadComments();
  }

  Future<void> loadComments() async {
    state = state.copyWith(status: CommentsStatus.loading);
    final result = await _getComments(_targetId);
    _apply(result);
  }

  Future<void> addComment(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final result = await _addComment(
      AddCommentParams(targetId: _targetId, text: trimmed),
    );
    _apply(result);
  }

  Future<void> toggleLike(String commentId) async {
    // Actualización optimista: el like se ve al instante.
    final optimistic = state.comments.map((c) {
      if (c.id != commentId) return c;
      return c.copyWith(
        isLiked: !c.isLiked,
        likesCount: c.isLiked ? c.likesCount - 1 : c.likesCount + 1,
      );
    }).toList();
    state = state.copyWith(comments: optimistic);

    final result = await _toggleLike(
      ToggleCommentLikeParams(targetId: _targetId, commentId: commentId),
    );
    _apply(result);
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
