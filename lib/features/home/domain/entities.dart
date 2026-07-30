import 'package:equatable/equatable.dart';

class PostEntity extends Equatable {
  final String id;
  final String authorId;
  final String authorName;
  final String authorAvatarUrl;
  final String imageUrl;
  final String title;
  final String description;
  final String timeAgo;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final bool isSaved;

  const PostEntity({
    required this.id,
    this.authorId = '',
    required this.authorName,
    required this.authorAvatarUrl,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.likesCount,
    required this.commentsCount,
    this.isLiked = false,
    this.isSaved = false,
  });

  PostEntity copyWith({
    int? likesCount,
    bool? isLiked,
    bool? isSaved,
  }) {
    return PostEntity(
      id: id,
      authorId: authorId,
      authorName: authorName,
      authorAvatarUrl: authorAvatarUrl,
      imageUrl: imageUrl,
      title: title,
      description: description,
      timeAgo: timeAgo,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  @override
  List<Object?> get props => [
    id,
    authorName,
    authorAvatarUrl,
    imageUrl,
    title,
    description,
    timeAgo,
    likesCount,
    commentsCount,
    isLiked,
    isSaved,
  ];
}
