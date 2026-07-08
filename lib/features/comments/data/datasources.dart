import '../../../core/error.dart';
import 'fixtures.dart';
import 'models.dart';

abstract class CommentsRemoteDataSource {
  Future<List<CommentModel>> getComments(String targetId);
  Future<List<CommentModel>> addComment({
    required String targetId,
    required String text,
    required String authorName,
  });
  Future<List<CommentModel>> toggleLike({
    required String targetId,
    required String commentId,
  });
}

/// Comentarios en memoria, agrupados por target (post o artículo).
/// Cada target arranca con los comentarios de ejemplo. Con FastAPI (y el NLP),
/// solo se reemplaza el cuerpo de estos métodos por llamadas al backend.
class CommentsRemoteDataSourceImpl implements CommentsRemoteDataSource {
  final Map<String, List<CommentModel>> _byTarget = {};

  /// Devuelve (creando si hace falta) la lista de un target,
  /// sembrada con los comentarios mock la primera vez.
  List<CommentModel> _threadFor(String targetId) {
    return _byTarget.putIfAbsent(
      targetId,
          () => CommentsFixtures.mock
          .map((c) => CommentModel(
        id: '${targetId}_${c.id}',
        targetId: targetId,
        authorName: c.authorName,
        authorAvatarUrl: c.authorAvatarUrl,
        text: c.text,
        timeAgo: c.timeAgo,
        likesCount: c.likesCount,
        isLiked: c.isLiked,
        parentId: c.parentId,
      ))
          .toList(),
    );
  }

  @override
  Future<List<CommentModel>> getComments(String targetId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return List.of(_threadFor(targetId));
    } catch (e) {
      throw ServerFailure('Error al cargar los comentarios: $e');
    }
  }

  @override
  Future<List<CommentModel>> addComment({
    required String targetId,
    required String text,
    required String authorName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      final thread = _threadFor(targetId);
      final comment = CommentModel(
        id: '${targetId}_${DateTime.now().millisecondsSinceEpoch}',
        targetId: targetId,
        authorName: authorName,
        authorAvatarUrl: '',
        text: text,
        timeAgo: 'Ahora',
      );
      thread.insert(0, comment);
      return List.of(thread);
    } catch (e) {
      throw ServerFailure('Error al publicar el comentario: $e');
    }
  }

  @override
  Future<List<CommentModel>> toggleLike({
    required String targetId,
    required String commentId,
  }) async {
    try {
      final thread = _threadFor(targetId);
      final index = thread.indexWhere((c) => c.id == commentId);
      if (index >= 0) {
        final c = thread[index];
        thread[index] = CommentModel(
          id: c.id,
          targetId: c.targetId,
          authorName: c.authorName,
          authorAvatarUrl: c.authorAvatarUrl,
          text: c.text,
          timeAgo: c.timeAgo,
          likesCount: c.isLiked ? c.likesCount - 1 : c.likesCount + 1,
          isLiked: !c.isLiked,
          parentId: c.parentId,
        );
      }
      return List.of(thread);
    } catch (e) {
      throw ServerFailure('Error al dar like: $e');
    }
  }
}