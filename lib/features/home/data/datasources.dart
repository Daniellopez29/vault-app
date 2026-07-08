import '../../../core/error.dart';
import 'fixtures.dart';
import 'models.dart';

abstract class HomeRemoteDataSource {
  Future<List<PostModel>> getFeedPosts();
  Future<void> toggleLike(String postId);
  Future<void> toggleSave(String postId);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  /// Estado local mutable de los posts mientras no hay backend.
  final List<PostModel> _posts = List.of(HomeFeedFixtures.mockPosts);

  @override
  Future<List<PostModel>> getFeedPosts() async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return List.of(_posts);
    } catch (e) {
      throw ServerFailure('Error al cargar el feed: $e');
    }
  }

  @override
  Future<void> toggleLike(String postId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;
    final post = _posts[index];
    _posts[index] = PostModel(
      id: post.id,
      authorName: post.authorName,
      authorAvatarUrl: post.authorAvatarUrl,
      imageUrl: post.imageUrl,
      title: post.title,
      description: post.description,
      timeAgo: post.timeAgo,
      likesCount: post.isLiked ? post.likesCount - 1 : post.likesCount + 1,
      commentsCount: post.commentsCount,
      isLiked: !post.isLiked,
      isSaved: post.isSaved,
    );
  }

  @override
  Future<void> toggleSave(String postId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;
    final post = _posts[index];
    _posts[index] = PostModel(
      id: post.id,
      authorName: post.authorName,
      authorAvatarUrl: post.authorAvatarUrl,
      imageUrl: post.imageUrl,
      title: post.title,
      description: post.description,
      timeAgo: post.timeAgo,
      likesCount: post.likesCount,
      commentsCount: post.commentsCount,
      isLiked: post.isLiked,
      isSaved: !post.isSaved,
    );
  }
}