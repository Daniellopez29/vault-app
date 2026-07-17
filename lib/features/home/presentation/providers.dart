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

  const FeedState({
    this.status = FeedStatus.initial,
    this.posts = const [],
    this.errorMessage,
  });

  FeedState copyWith({
    FeedStatus? status,
    List<PostEntity>? posts,
    String? errorMessage,
  }) {
    return FeedState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      errorMessage: errorMessage,
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
    state = state.copyWith(
      posts: state.posts
          .map((p) => p.id == postId ? p.copyWith(isSaved: !p.isSaved) : p)
          .toList(),
    );
    await _toggleSave(postId);
  }
}
