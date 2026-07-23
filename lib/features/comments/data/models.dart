import '../../../core/time_ago.dart';
import '../domain/entities.dart';

class CommentModel extends CommentEntity {
  const CommentModel({
    required super.id,
    required super.targetId,
    required super.authorName,
    required super.authorAvatarUrl,
    required super.text,
    required super.timeAgo,
    super.likesCount = 0,
    super.isLiked = false,
    super.parentId,
  });

  /// Respuesta de GET/POST /api/v1/posts/{id}/comments o
  /// /api/v1/assets/{id}/comments del API Go. [targetId] se recibe como
  /// parámetro (ya lo conoce el llamador) en vez de leerse del JSON, porque
  /// la key del padre cambia según el origen (`post_id` vs `asset_id`). No
  /// hay likes de comentarios en el backend (sin tabla comment_likes) --
  /// queda en false/0 y el like es solo estado local en la sesión.
  factory CommentModel.fromJson(Map<String, dynamic> json, {required String targetId}) {
    return CommentModel(
      id: json['id'] as String,
      targetId: targetId,
      authorName: json['author_name'] as String? ?? '',
      authorAvatarUrl: json['author_avatar_url'] as String? ?? '',
      text: json['content'] as String? ?? '',
      timeAgo: timeAgoFrom(json['created_at'] as String? ?? ''),
      likesCount: 0,
      isLiked: false,
      parentId: null,
    );
  }
}