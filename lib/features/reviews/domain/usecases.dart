import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error.dart';
import 'entities.dart';
import 'repositories.dart';

class GetReviewsForProviderUseCase {
  final ReviewsRepository repository;
  const GetReviewsForProviderUseCase(this.repository);

  Future<Either<Failure, List<ReviewEntity>>> call(String providerId) =>
      repository.getReviewsForProvider(providerId);
}

class AddReviewUseCase {
  final ReviewsRepository repository;
  const AddReviewUseCase(this.repository);

  Future<Either<Failure, List<ReviewEntity>>> call(AddReviewParams params) =>
      repository.addReview(providerId: params.providerId, content: params.content);
}

class ToggleReviewLikeUseCase {
  final ReviewsRepository repository;
  const ToggleReviewLikeUseCase(this.repository);

  Future<Either<Failure, void>> call(String reviewId, bool currentlyLiked) =>
      repository.toggleLike(reviewId, currentlyLiked);
}

class AddReviewParams extends Equatable {
  final String providerId;
  final String content;

  const AddReviewParams({required this.providerId, required this.content});

  @override
  List<Object?> get props => [providerId, content];
}
