import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/usecase.dart';
import '../../home/domain/entities.dart';
import '../data/datasources.dart';
import '../data/repositories.dart';
import '../domain/repositories.dart';
import '../domain/usecases.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepositoryImpl(
    localDataSource: FavoritesLocalDataSourceImpl(),
  );
});

final getSavedPostsUseCaseProvider = Provider<GetSavedPostsUseCase>((ref) {
  return GetSavedPostsUseCase(ref.read(favoritesRepositoryProvider));
});

final removeSavedPostUseCaseProvider = Provider<RemoveSavedPostUseCase>((ref) {
  return RemoveSavedPostUseCase(ref.read(favoritesRepositoryProvider));
});

// ─── STATE ────────────────────────────────────────────────────────────────────

enum FavoritesStatus { initial, loading, loaded, error }

class FavoritesState {
  final FavoritesStatus status;
  final List<PostEntity> posts;
  final String? errorMessage;

  const FavoritesState({
    this.status = FavoritesStatus.initial,
    this.posts = const [],
    this.errorMessage,
  });

  FavoritesState copyWith({
    FavoritesStatus? status,
    List<PostEntity>? posts,
    String? errorMessage,
  }) {
    return FavoritesState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      errorMessage: errorMessage,
    );
  }
}

final favoritesControllerProvider =
StateNotifierProvider<FavoritesController, FavoritesState>((ref) {
  return FavoritesController(
    getSavedPosts: ref.read(getSavedPostsUseCaseProvider),
    removeSavedPost: ref.read(removeSavedPostUseCaseProvider),
  );
});

class FavoritesController extends StateNotifier<FavoritesState> {
  final GetSavedPostsUseCase _getSavedPosts;
  final RemoveSavedPostUseCase _removeSavedPost;

  FavoritesController({
    required this._getSavedPosts,
    required RemoveSavedPostUseCase removeSavedPost,
  })  : _removeSavedPost = removeSavedPost,
        super(const FavoritesState()) {
    loadSavedPosts();
  }

  Future<void> loadSavedPosts() async {
    state = state.copyWith(status: FavoritesStatus.loading);
    final result = await _getSavedPosts(const NoParams());
    result.fold(
          (failure) => state = state.copyWith(
          status: FavoritesStatus.error, errorMessage: failure.message),
          (posts) => state = state.copyWith(
          status: FavoritesStatus.loaded, posts: posts),
    );
  }

  Future<void> removeSavedPost(String postId) async {
    final result = await _removeSavedPost(postId);
    result.fold(
          (failure) => state = state.copyWith(errorMessage: failure.message),
          (_) => loadSavedPosts(),
    );
  }
}