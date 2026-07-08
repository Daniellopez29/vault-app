import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/usecase.dart';
import '../../auth/presentation/providers.dart';
import '../../profile/domain/entities.dart';
import '../../profile/presentation/providers.dart';
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
  final controller = FeedController(
    ref.read(getFeedPostsUseCaseProvider),
    ref.read(toggleLikeUseCaseProvider),
    ref.read(toggleSaveUseCaseProvider),
    ref,
  );
  // Cuando cambian los activos publicados del inventario, el Feed se recombina.
  ref.listen(profileAssetsControllerProvider, (previous, next) {
    controller.refreshPublished();
  });
  return controller;
});

class FeedController extends StateNotifier<FeedState> {
  final GetFeedPostsUseCase _getFeedPosts;
  final ToggleLikeUseCase _toggleLike;
  final ToggleSaveUseCase _toggleSave;
  final Ref _ref;

  // Posts mock cacheados (con su estado de like/save vivo).
  List<PostEntity> _mockPosts = const [];

  FeedController(
      this._getFeedPosts, this._toggleLike, this._toggleSave, this._ref)
      : super(const FeedState()) {
    loadFeed();
  }

  Future<void> loadFeed() async {
    state = state.copyWith(status: FeedStatus.loading);
    final result = await _getFeedPosts(const NoParams());
    result.fold(
          (failure) => state = state.copyWith(
          status: FeedStatus.error, errorMessage: failure.message),
          (posts) {
        _mockPosts = posts;
        state =
            state.copyWith(status: FeedStatus.loaded, posts: _combinedPosts());
      },
    );
  }

  /// Recombina tus publicaciones + mock, sin volver a pedir el mock.
  void refreshPublished() {
    if (state.status != FeedStatus.loaded) return;
    state = state.copyWith(posts: _combinedPosts());
  }

  /// Tus publicaciones primero, luego el feed mock.
  List<PostEntity> _combinedPosts() {
    final published = _ref
        .read(profileAssetsControllerProvider)
        .assets
        .where((asset) => asset.isPublished)
        .map(_assetToPost)
        .toList();
    return [...published, ..._mockPosts];
  }

  /// Convierte un activo publicado en un post del Feed.
  PostEntity _assetToPost(AssetEntity asset) {
    final authorName =
        _ref.read(authControllerProvider).user?.fullName ?? 'Tú';
    return PostEntity(
      id: asset.id,
      authorName: authorName,
      authorAvatarUrl: '',
      imageUrl: asset.imageUrl,
      title: asset.name,
      description: asset.publishCaption ?? '',
      timeAgo: 'Ahora',
      likesCount: 0,
      commentsCount: 0,
    );
  }

  List<PostEntity> _applyLike(List<PostEntity> posts, String postId) {
    return posts.map((p) {
      if (p.id != postId) return p;
      return p.copyWith(
        isLiked: !p.isLiked,
        likesCount: p.isLiked ? p.likesCount - 1 : p.likesCount + 1,
      );
    }).toList();
  }

  List<PostEntity> _applySave(List<PostEntity> posts, String postId) {
    return posts
        .map((p) => p.id == postId ? p.copyWith(isSaved: !p.isSaved) : p)
        .toList();
  }

  Future<void> toggleLike(String postId) async {
    _mockPosts = _applyLike(_mockPosts, postId);
    state = state.copyWith(posts: _applyLike(state.posts, postId));
    await _toggleLike(postId);
  }

  Future<void> toggleSave(String postId) async {
    _mockPosts = _applySave(_mockPosts, postId);
    state = state.copyWith(posts: _applySave(state.posts, postId));
    await _toggleSave(postId);
  }
}