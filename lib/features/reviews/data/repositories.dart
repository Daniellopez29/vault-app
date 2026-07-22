import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';
import 'datasources.dart';

class ReviewsRepositoryImpl implements ReviewsRepository {
  final ReviewsRemoteDataSource remoteDataSource;

  const ReviewsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ReviewEntity>>> getReviewsForProvider(String providerId) =>
      _guard(() => remoteDataSource.getReviewsForProvider(providerId));

  @override
  Future<Either<Failure, List<ReviewEntity>>> addReview({
    required String providerId,
    required String content,
  }) =>
      _guard(() => remoteDataSource.addReview(providerId: providerId, content: content));

  @override
  Future<Either<Failure, void>> toggleLike(String reviewId, bool currentlyLiked) async {
    try {
      await remoteDataSource.toggleLike(reviewId, currentlyLiked);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  Future<Either<Failure, List<ReviewEntity>>> _guard(
      Future<List<ReviewEntity>> Function() action) async {
    try {
      final reviews = await action();
      return Right(reviews);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }
}
