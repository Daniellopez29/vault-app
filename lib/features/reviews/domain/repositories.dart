import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import 'entities.dart';

abstract class ReviewsRepository {
  Future<Either<Failure, List<ReviewEntity>>> getReviewsForProvider(String providerId);

  /// Crea una reseña y devuelve la lista actualizada del proveedor.
  Future<Either<Failure, List<ReviewEntity>>> addReview({
    required String providerId,
    required String content,
  });

  Future<Either<Failure, void>> toggleLike(String reviewId, bool currentlyLiked);
}
