import '../../../core/api_client.dart';
import '../../../core/error.dart';
import 'models.dart';

abstract class ReviewsRemoteDataSource {
  Future<List<ReviewModel>> getReviewsForProvider(String providerId);
  Future<List<ReviewModel>> addReview({required String providerId, required String content});
  Future<void> toggleLike(String reviewId, bool currentlyLiked);
}

class ReviewsRemoteDataSourceImpl implements ReviewsRemoteDataSource {
  final ApiClient _client;

  ReviewsRemoteDataSourceImpl(this._client);

  @override
  Future<List<ReviewModel>> getReviewsForProvider(String providerId) async {
    try {
      final body =
          await _client.get('/reviews', query: {'provider_id': providerId}, auth: false);
      final list = body as List<dynamic>? ?? const [];
      return list.map((e) => ReviewModel.fromJson(e as Map<String, dynamic>)).toList();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al cargar las reseñas: $e');
    }
  }

  @override
  Future<List<ReviewModel>> addReview({
    required String providerId,
    required String content,
  }) async {
    try {
      await _client.post('/reviews', body: {'provider_id': providerId, 'content': content});
      return getReviewsForProvider(providerId);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al publicar la reseña: $e');
    }
  }

  @override
  Future<void> toggleLike(String reviewId, bool currentlyLiked) async {
    try {
      if (currentlyLiked) {
        await _client.delete('/reviews/$reviewId/likes');
      } else {
        await _client.post('/reviews/$reviewId/likes');
      }
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al dar like: $e');
    }
  }
}
