import '../../../core/time_ago.dart';
import '../domain/entities.dart';

class PostModel extends PostEntity {
  const PostModel({
    required super.id,
    required super.authorName,
    required super.authorAvatarUrl,
    required super.imageUrl,
    required super.title,
    required super.description,
    required super.timeAgo,
    required super.likesCount,
    required super.commentsCount,
    super.isLiked = false,
    super.isSaved = false,
  });

  /// Respuesta de GET/POST /api/v1/posts del API Go. El backend no separa
  /// título/descripción (solo `content`) ni tiene "guardados" -- se dejan
  /// vacío/false y esos campos quedan como estado local en la UI.
  factory PostModel.fromJson(Map<String, dynamic> json) {
    final photos = json['photos'] as List<dynamic>? ?? const [];
    final firstPhoto =
        photos.isNotEmpty ? (photos.first as Map<String, dynamic>)['url'] as String? : null;

    return PostModel(
      id: json['id'] as String,
      authorName: json['author_name'] as String? ?? '',
      authorAvatarUrl: json['author_avatar_url'] as String? ?? '',
      imageUrl: firstPhoto ?? '',
      title: '',
      description: json['content'] as String? ?? '',
      timeAgo: timeAgoFrom(json['created_at'] as String? ?? ''),
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      isLiked: false,
      isSaved: false,
    );
  }
}
