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

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      targetId: json['targetId'] as String,
      authorName: json['authorName'] as String,
      authorAvatarUrl: json['authorAvatarUrl'] as String? ?? '',
      text: json['text'] as String,
      timeAgo: json['timeAgo'] as String? ?? '',
      likesCount: json['likesCount'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      parentId: json['parentId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'targetId': targetId,
    'authorName': authorName,
    'authorAvatarUrl': authorAvatarUrl,
    'text': text,
    'timeAgo': timeAgo,
    'likesCount': likesCount,
    'isLiked': isLiked,
    'parentId': parentId,
  };
}