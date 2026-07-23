import 'package:equatable/equatable.dart';

/// A qué tipo de recurso pertenece un comentario -- el backend tiene tablas
/// separadas (`comments` para posts, `asset_comments` para productos), así
/// que hace falta saber cuál para elegir la ruta correcta.
enum CommentTargetType { post, asset }

/// Identifica de forma única el objetivo de un hilo de comentarios (un post
/// o un producto del marketplace).
class CommentsTarget extends Equatable {
  final String id;
  final CommentTargetType type;

  const CommentsTarget({required this.id, required this.type});

  @override
  List<Object?> get props => [id, type];
}

/// Un comentario sobre un post del Feed o un artículo del Marketplace.
/// [targetId] es a qué pertenece (post o artículo) — eso la hace reutilizable.
/// [parentId] queda listo para respuestas anidadas (hilos), aún no usado.
class CommentEntity extends Equatable {
  final String id;
  final String targetId;
  final String authorName;
  final String authorAvatarUrl;
  final String text;
  final String timeAgo;
  final int likesCount;
  final bool isLiked;
  final String? parentId;

  const CommentEntity({
    required this.id,
    required this.targetId,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.text,
    required this.timeAgo,
    this.likesCount = 0,
    this.isLiked = false,
    this.parentId,
  });

  CommentEntity copyWith({
    int? likesCount,
    bool? isLiked,
  }) {
    return CommentEntity(
      id: id,
      targetId: targetId,
      authorName: authorName,
      authorAvatarUrl: authorAvatarUrl,
      text: text,
      timeAgo: timeAgo,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      parentId: parentId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    targetId,
    authorName,
    authorAvatarUrl,
    text,
    timeAgo,
    likesCount,
    isLiked,
    parentId,
  ];
}