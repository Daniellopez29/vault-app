import '../../../core/api_client.dart';
import '../../../core/error.dart';
import '../domain/repositories.dart';
import 'models.dart';

abstract class HomeRemoteDataSource {
  Future<List<PostModel>> getFeedPosts();
  Future<void> toggleLike(String postId, bool currentlyLiked);
  Future<void> toggleSave(String postId, bool currentlySaved);
  Future<void> createPost({required String content, required List<PostImageUpload> images});
  Future<void> deletePost(String postId);
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
      throw ServerFailure('Error al cargar el feed: ' + e.toString());
    }
  }

  @override
  Future<void> toggleLike(String postId, bool currentlyLiked) async {
    try {
      final path = '/posts/' + postId + '/likes';
      if (currentlyLiked) {
        await _client.delete(path);
      } else {
        await _client.post(path);
      }
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al dar like: ' + e.toString());
    }
  }

  @override
  Future<void> toggleSave(String postId, bool currentlySaved) async {
    try {
      final path = '/posts/' + postId + '/saves';
      if (currentlySaved) {
        await _client.delete(path);
      } else {
        await _client.post(path);
      }
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al guardar: ' + e.toString());
    }
  }

  @override
  Future<void> createPost({
    required String content,
    required List<PostImageUpload> images,
  }) async {
    final body = await _client.post('/posts', body: {'content': content});
    final postId = (body as Map<String, dynamic>)['id'] as String;
    for (final image in images) {
      await _client.postMultipart(
        '/posts/' + postId + '/photos',
        bytes: image.bytes,
        filename: image.filename,
        fieldName: 'image',
      );
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      await _client.delete('/posts/' + postId);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al eliminar: ' + e.toString());
    }
  }
}
