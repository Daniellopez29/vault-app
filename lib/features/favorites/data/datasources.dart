import '../../../core/api_client.dart';
import '../../../core/error.dart';
import '../../home/data/models.dart';

abstract class FavoritesRemoteDataSource {
  Future<List<PostModel>> getSavedPosts();
  Future<void> removeSavedPost(String postId);
}

class FavoritesRemoteDataSourceImpl implements FavoritesRemoteDataSource {
  final ApiClient _client;

  FavoritesRemoteDataSourceImpl(this._client);

  @override
  Future<List<PostModel>> getSavedPosts() async {
    try {
      final body = await _client.get('/posts/saved');
      final list = body as List<dynamic>? ?? const [];
      return list.map((e) => PostModel.fromJson(e as Map<String, dynamic>)).toList();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al cargar favoritos: $e');
    }
  }

  @override
  Future<void> removeSavedPost(String postId) async {
    try {
      await _client.delete('/posts/$postId/saves');
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al quitar de favoritos: $e');
    }
  }
}
