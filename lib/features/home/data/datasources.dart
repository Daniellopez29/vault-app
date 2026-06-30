import '../../../core/error.dart';
import 'models.dart';

abstract class HomeRemoteDataSource {
  Future<List<PostModel>> getFeedPosts();
  Future<void> toggleLike(String postId);
  Future<void> toggleSave(String postId);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  // TODO: reemplazar por llamadas reales a la API cuando el backend esté listo.

  final List<PostModel> _mockPosts = [
    const PostModel(
      id: '1',
      authorName: 'Sr.Sneakers',
      authorAvatarUrl: '',
      imageUrl: 'assets/images/mock/sneaker1.jpg',
      title: 'Tenis ColorFull A9',
      description:
      'Acabo de registrar esta joya en la app. ¿Qué dicen, se queda para la colección personal a largo plazo o la movemos pronto en el mercado?',
      timeAgo: '3 días atrás',
      likesCount: 187,
      commentsCount: 155,
    ),
    const PostModel(
      id: '2',
      authorName: 'Sr.Sneakers',
      authorAvatarUrl: '',
      imageUrl: 'assets/images/mock/sneaker2.jpg',
      title: 'Tenis ColorFull A9',
      description:
      'Acabo de registrar esta joya en la app. ¿Qué dicen, se queda para la colección personal a largo plazo o la movemos pronto en el mercado?',
      timeAgo: '3 días atrás',
      likesCount: 187,
      commentsCount: 155,
    ),
    const PostModel(
      id: '3',
      authorName: 'Sr.Rolex',
      authorAvatarUrl: '',
      imageUrl: 'assets/images/mock/reloj1.jpg',
      title: 'Reloj Rolex Gemini',
      description:
      'Acabo de registrar esta joya en la app. ¿Qué dicen, se queda para la colección personal a largo plazo o la movemos pronto en el mercado?',
      timeAgo: '3 días atrás',
      likesCount: 187,
      commentsCount: 155,
    ),
  ];

  @override
  Future<List<PostModel>> getFeedPosts() async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return List.of(_mockPosts);
    } catch (e) {
      throw ServerFailure('Error al cargar el feed: $e');
    }
  }

  @override
  Future<void> toggleLike(String postId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _mockPosts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _mockPosts[index];
      _mockPosts[index] = PostModel(
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
  }

  @override
  Future<void> toggleSave(String postId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _mockPosts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _mockPosts[index];
      _mockPosts[index] = PostModel(
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
}