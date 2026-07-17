import '../../../core/api_client.dart';
import '../../../core/error.dart';
import '../domain/repositories.dart';
import 'models.dart';

abstract class HomeRemoteDataSource {
  Future<List<PostModel>> getFeedPosts();
  Future<void> toggleLike(String postId, bool currentlyLiked);
  Future<void> toggleSave(String postId);
  Future<void> createPost({required String content, required List<PostImageUpload> images});
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final ApiClient _client;

  HomeRemoteDataSourceImpl(this._client);

  @override
  Future<List<PostModel>> getFeedPosts() async {
    try {
      final body = await _client.get('/posts', auth: false);
      final list = body as List<dynamic>? ?? const [];
      return list.map((e) => PostModel.fromJson(e as Map<String, dynamic>)).toList();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al cargar el feed: $e');
    }
  }

  @override
  Future<void> toggleLike(String postId, bool currentlyLiked) async {
    try {
      if (currentlyLiked) {
        await _client.delete('/posts/$postId/likes');
      } else {
        await _client.post('/posts/$postId/likes');
      }
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al dar like: $e');
    }
  }

  @override
  Future<void> toggleSave(String postId) async {
    // No existe tabla de "guardados" en el backend. La UI mantiene el
    // estado local; aquí no hay nada que persistir.
  }

  @override
  Future<void> createPost({
    required String content,
    required List<PostImageUpload> images,
  }) async {
    // El content pasa por moderación síncrona en el backend (puede tirar
    // ModerationFailure) -- si eso pasa, ni el post ni las fotos se suben.
    final body = await _client.post('/posts', body: {'content': content});
    final postId = (body as Map<String, dynamic>)['id'] as String;

    // El post ya quedó creado en este punto; si una foto falla, la
    // excepción se propaga tal cual (ApiClient ya la deja como Failure).
    for (final image in images) {
      await _client.postMultipart(
        '/posts/$postId/photos',
        bytes: image.bytes,
        filename: image.filename,
        fieldName: 'image',
      );
    }
  }
}
