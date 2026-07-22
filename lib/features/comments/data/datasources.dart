import '../../../core/api_client.dart';
import '../../../core/error.dart';
import 'models.dart';

abstract class CommentsRemoteDataSource {
  Future<List<CommentModel>> getComments(String targetId);
  Future<List<CommentModel>> addComment({
    required String targetId,
    required String text,
  });
}

/// [targetId] es el id de un post -- comentarios solo existen sobre posts
/// en el backend real (no hay "artículos de marketplace" que comentar).
class CommentsRemoteDataSourceImpl implements CommentsRemoteDataSource {
  final ApiClient _client;

  CommentsRemoteDataSourceImpl(this._client);

  @override
  Future<List<CommentModel>> getComments(String targetId) async {
    try {
      final body = await _client.get('/posts/$targetId/comments', auth: false);
      final list = body as List<dynamic>? ?? const [];
      return list.map((e) => CommentModel.fromJson(e as Map<String, dynamic>)).toList();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al cargar los comentarios: $e');
    }
  }

  @override
  Future<List<CommentModel>> addComment({
    required String targetId,
    required String text,
  }) async {
    try {
      await _client.post('/posts/$targetId/comments', body: {'content': text});
      return getComments(targetId);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al publicar el comentario: $e');
    }
  }
}
