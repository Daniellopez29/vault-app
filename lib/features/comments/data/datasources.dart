import '../../../core/api_client.dart';
import '../../../core/error.dart';
import '../domain/entities.dart';
import 'models.dart';

abstract class CommentsRemoteDataSource {
  Future<List<CommentModel>> getComments(CommentsTarget target);
  Future<List<CommentModel>> addComment({
    required CommentsTarget target,
    required String text,
  });
}

/// El backend tiene dos tablas separadas -- `comments` (posts) y
/// `asset_comments` (productos) -- con la misma forma de respuesta salvo la
/// key del padre (`post_id` vs `asset_id`), por eso el datasource elige la
/// ruta según `target.type` pero comparte todo lo demás.
class CommentsRemoteDataSourceImpl implements CommentsRemoteDataSource {
  final ApiClient _client;

  CommentsRemoteDataSourceImpl(this._client);

  String _basePath(CommentsTarget target) => switch (target.type) {
        CommentTargetType.post => '/posts/${target.id}/comments',
        CommentTargetType.asset => '/assets/${target.id}/comments',
      };

  @override
  Future<List<CommentModel>> getComments(CommentsTarget target) async {
    try {
      final body = await _client.get(_basePath(target), auth: false);
      final list = body as List<dynamic>? ?? const [];
      return list
          .map((e) => CommentModel.fromJson(e as Map<String, dynamic>, targetId: target.id))
          .toList();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al cargar los comentarios: $e');
    }
  }

  @override
  Future<List<CommentModel>> addComment({
    required CommentsTarget target,
    required String text,
  }) async {
    try {
      await _client.post(_basePath(target), body: {'content': text});
      return getComments(target);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al publicar el comentario: $e');
    }
  }
}
