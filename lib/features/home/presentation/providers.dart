import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/usecase.dart';
import '../data/datasources.dart';
import '../data/repositories.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';
import '../domain/usecases.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepositoryImpl(remoteDataSource: HomeRemoteDataSourceImpl());
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
    // Actualización optimista
    final updated = state.posts.map((p) {
      if (p.id == postId) {
        return PostEntity(
          id: p.id,
          authorName: p.authorName,
          authorAvatarUrl: p.authorAvatarUrl,
          imageUrl: p.imageUrl,
          title: p.title,
          description: p.description,
          timeAgo: p.timeAgo,
          likesCount: p.isLiked ? p.likesCount - 1 : p.likesCount + 1,
          commentsCount: p.commentsCount,
          isLiked: !p.isLiked,
          isSaved: p.isSaved,
        );
      }
      return p;
    }).toList();
    state = state.copyWith(posts: updated);
    await _toggleLike(postId);
  }

  Future<void> toggleSave(String postId) async {
    final updated = state.posts.map((p) {
      if (p.id == postId) {
        return PostEntity(
          id: p.id,
          authorName: p.authorName,
          authorAvatarUrl: p.authorAvatarUrl,
          imageUrl: p.imageUrl,
          title: p.title,
          description: p.description,
          timeAgo: p.timeAgo,
          likesCount: p.likesCount,
          commentsCount: p.commentsCount,
          isLiked: p.isLiked,
          isSaved: !p.isSaved,
        );
      }
      return p;
    }).toList();
    state = state.copyWith(posts: updated);
    await _toggleSave(postId);
  }
}