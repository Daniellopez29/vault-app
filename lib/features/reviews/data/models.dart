import '../../../core/time_ago.dart';
import '../domain/entities.dart';

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.providerId,
    required super.authorName,
    required super.authorAvatarUrl,
    required super.content,
    required super.timeAgo,
    super.likesCount = 0,
    super.isLiked = false,
  });

  /// Respuesta de GET/POST /api/v1/reviews del API Go.
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      providerId: json['provider_id'] as String? ?? '',
      authorName: json['author_name'] as String? ?? '',
      authorAvatarUrl: json['author_avatar_url'] as String? ?? '',
      content: json['content'] as String? ?? '',
      timeAgo: timeAgoFrom(json['created_at'] as String? ?? ''),
      likesCount: json['likes_count'] as int? ?? 0,
      isLiked: false,
    );
  }
}
