import 'package:equatable/equatable.dart';

/// Una reseña que un usuario le dejó a un proveedor (restaurador/servicio).
class ReviewEntity extends Equatable {
  final String id;
  final String providerId;
  final String authorName;
  final String authorAvatarUrl;
  final String content;
  final String timeAgo;
  final int likesCount;
  final bool isLiked;

  const ReviewEntity({
    required this.id,
    required this.providerId,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.content,
    required this.timeAgo,
    this.likesCount = 0,
    this.isLiked = false,
  });

  ReviewEntity copyWith({int? likesCount, bool? isLiked}) {
    return ReviewEntity(
      id: id,
      providerId: providerId,
      authorName: authorName,
      authorAvatarUrl: authorAvatarUrl,
      content: content,
      timeAgo: timeAgo,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  @override
  List<Object?> get props =>
      [id, providerId, authorName, authorAvatarUrl, content, timeAgo, likesCount, isLiked];
}
