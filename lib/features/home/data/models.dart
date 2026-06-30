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

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      authorName: json['authorName'] as String,
      authorAvatarUrl: json['authorAvatarUrl'] as String,
      imageUrl: json['imageUrl'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      timeAgo: json['timeAgo'] as String,
      likesCount: json['likesCount'] as int,
      commentsCount: json['commentsCount'] as int,
      isLiked: json['isLiked'] as bool? ?? false,
      isSaved: json['isSaved'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorName': authorName,
      'authorAvatarUrl': authorAvatarUrl,
      'imageUrl': imageUrl,
      'title': title,
      'description': description,
      'timeAgo': timeAgo,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'isLiked': isLiked,
      'isSaved': isSaved,
    };
  }
}