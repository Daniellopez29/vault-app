import '../../../core/error.dart';
import '../../home/data/fixtures.dart';
import '../../home/data/models.dart';

abstract class FavoritesLocalDataSource {
  Future<List<PostModel>> getSavedPosts();
  Future<void> removeSavedPost(String postId);
}

class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  // Posts guardados en memoria — se reemplazará por base de datos real
  final List<PostModel> _savedPosts = List.of(HomeFeedFixtures.mockPosts);

  @override
  Future<List<PostModel>> getSavedPosts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return List.of(_savedPosts);
    } catch (e) {
      throw ServerFailure('Error al cargar favoritos: $e');
    }
  }

  @override
  Future<void> removeSavedPost(String postId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _savedPosts.removeWhere((p) => p.id == postId);
  }
}