import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/usecase.dart';
import '../data/datasources.dart';
import '../data/repositories.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';
import '../domain/usecases.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepositoryImpl(
    remoteDataSource: HomeRemoteDataSourceImpl(ref.read(apiClientProvider)),
  );
});

final getFeedPostsUseCaseProvider = Provider<GetFeedPostsUseCase>((ref) {
  return GetFeedPostsUseCase(ref.read(homeRepositoryProvider));
});

final toggleLikeUseCaseProvider = Provider<ToggleLikeUseCase>((ref) {
  return ToggleLikeUseCase(ref.read(homeRepositoryProvider));
});

final toggleSaveUseCaseProvider = Provider<ToggleSaveUseCase>((ref) {
  return ToggleSaveUseCase(ref.read(homeRepositoryProvider));
});

final createPostUseCaseProvider = Provider<CreatePostUseCase>((ref) {
  return CreatePostUseCase(ref.read(homeRepositoryProvider));
});

enum FeedStatus { initial, loading, loaded, error }

class FeedState {
  final FeedStatus status;
  final List<PostEntity> posts;
  final String? errorMessage;
  final String searchQuery;

  const FeedState({
    this.status = FeedStatus.initial,
    this.posts = const [],
    this.errorMessage,
    this.searchQuery = '',
  });

  /// Publicaciones que ve la UI: aplica el filtro de búsqueda sobre la lista
  /// completa. Es un cálculo derivado, no un estado aparte, para que la lógica
  /// de likes/guardados siga operando siempre sobre [posts] sin cambios.
  List<PostEntity> get visiblePosts {
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return posts;
    return posts.where((p) {
      return p.title.toLowerCase().contains(q) ||
          p.authorName.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q);
    }).toList();
  }

  bool get isSearching => searchQuery.trim().isNotEmpty;

  FeedState copyWith({
    FeedStatus? status,
    List<PostEntity>? posts,
    String? errorMessage,
    String? searchQuery,
  }) {
    return FeedState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

final feedControllerProvider =
StateNotifierProvider<FeedController, FeedState>((ref) {
  return FeedController(
    ref.read(getFeedPostsUseCaseProvider),
    ref.read(toggleLikeUseCaseProvider),
    ref.read(toggleSaveUseCaseProvider),
  );
});

class FeedController extends StateNotifier<FeedState> {
  final GetFeedPostsUseCase _getFeedPosts;
  final ToggleLikeUseCase _toggleLike;
  final ToggleSaveUseCase _toggleSave;

  FeedController(this._getFeedPosts, this._toggleLike, this._toggleSave)
      : super(const FeedState()) {
    loadFeed();
  }

  Future<void> loadFeed() async {
    state = state.copyWith(status: FeedStatus.loading);
    final result = await _getFeedPosts(const NoParams());
    result.fold(
          (failure) => state = state.copyWith(
          status: FeedStatus.error, errorMessage: failure.message),
          (posts) => state = state.copyWith(status: FeedStatus.loaded, posts: posts),
    );
  }

  /// Actualiza el texto de búsqueda. El filtrado es local sobre las
  /// publicaciones ya cargadas; no vuelve a pedirlas al backend.
  void search(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearSearch() => search('');

  Future<void> toggleLike(String postId) async {
    final wasLiked = state.posts.firstWhere((p) => p.id == postId).isLiked;

    // Actualización optimista.
    state = state.copyWith(
      posts: state.posts.map((p) {
        if (p.id != postId) return p;
        return p.copyWith(
          isLiked: !p.isLiked,
          likesCount: p.isLiked ? p.likesCount - 1 : p.likesCount + 1,
        );
      }).toList(),
    );

    final result = await _toggleLike(postId, wasLiked);
    result.fold(
      (failure) {
        // Revierte si el backend lo rechazó.
        state = state.copyWith(
          posts: state.posts.map((p) {
            if (p.id != postId) return p;
            return p.copyWith(
              isLiked: wasLiked,
              likesCount: wasLiked ? p.likesCount + 1 : p.likesCount - 1,
            );
          }).toList(),
          errorMessage: failure.message,
        );
      },
      (_) {},
    );
  }

  Future<void> toggleSave(String postId) async {
    final wasSaved = state.posts.firstWhere((p) => p.id == postId).isSaved;

    // Actualización optimista.
    state = state.copyWith(
      posts: state.posts
          .map((p) => p.id == postId ? p.copyWith(isSaved: !p.isSaved) : p)
          .toList(),
    );

    final result = await _toggleSave(postId, wasSaved);
    result.fold(
      (failure) {
        // Revierte si el backend lo rechazó.
        state = state.copyWith(
          posts: state.posts
              .map((p) => p.id == postId ? p.copyWith(isSaved: wasSaved) : p)
              .toList(),
          errorMessage: failure.message,
        );
      },
      (_) {},
    );
  }
}
