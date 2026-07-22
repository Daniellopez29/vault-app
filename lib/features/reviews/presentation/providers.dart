import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../data/datasources.dart';
import '../data/repositories.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';
import '../domain/usecases.dart';

final reviewsRepositoryProvider = Provider<ReviewsRepository>((ref) {
  return ReviewsRepositoryImpl(
    remoteDataSource: ReviewsRemoteDataSourceImpl(ref.read(apiClientProvider)),
  );
});

final getReviewsForProviderUseCaseProvider =
Provider<GetReviewsForProviderUseCase>((ref) {
  return GetReviewsForProviderUseCase(ref.read(reviewsRepositoryProvider));
});

final toggleReviewLikeUseCaseProvider = Provider<ToggleReviewLikeUseCase>((ref) {
  return ToggleReviewLikeUseCase(ref.read(reviewsRepositoryProvider));
});

enum ReviewsStatus { initial, loading, loaded, error }

class ReviewsState {
  final ReviewsStatus status;
  final List<ReviewEntity> reviews;
  final String? errorMessage;

  const ReviewsState({
    this.status = ReviewsStatus.initial,
    this.reviews = const [],
    this.errorMessage,
  });

  ReviewsState copyWith({
    ReviewsStatus? status,
    List<ReviewEntity>? reviews,
    String? errorMessage,
  }) {
    return ReviewsState(
      status: status ?? this.status,
      reviews: reviews ?? this.reviews,
      errorMessage: errorMessage,
    );
  }
}

/// Un controller por proveedor -- `.family` recibe el providerId (en la
/// pestaña "Mis Reseñas" es siempre el propio usuario autenticado).
final reviewsControllerProvider = StateNotifierProvider.family<ReviewsController,
    ReviewsState, String>((ref, providerId) {
  return ReviewsController(
    providerId: providerId,
    getReviews: ref.read(getReviewsForProviderUseCaseProvider),
    toggleLike: ref.read(toggleReviewLikeUseCaseProvider),
  );
});

class ReviewsController extends StateNotifier<ReviewsState> {
  final String _providerId;
  final GetReviewsForProviderUseCase _getReviews;
  final ToggleReviewLikeUseCase _toggleLike;

  ReviewsController({
    required this._providerId,
    required GetReviewsForProviderUseCase getReviews,
    required this._toggleLike,
  })  : _getReviews = getReviews,
        super(const ReviewsState()) {
    loadReviews();
  }

  Future<void> loadReviews() async {
    state = state.copyWith(status: ReviewsStatus.loading);
    final result = await _getReviews(_providerId);
    result.fold(
      (failure) =>
          state = state.copyWith(status: ReviewsStatus.error, errorMessage: failure.message),
      (reviews) => state = state.copyWith(status: ReviewsStatus.loaded, reviews: reviews),
    );
  }

  Future<void> toggleLike(String reviewId) async {
    final wasLiked = state.reviews.firstWhere((r) => r.id == reviewId).isLiked;
    state = state.copyWith(
      reviews: state.reviews.map((r) {
        if (r.id != reviewId) return r;
        return r.copyWith(
          isLiked: !r.isLiked,
          likesCount: r.isLiked ? r.likesCount - 1 : r.likesCount + 1,
        );
      }).toList(),
    );
    await _toggleLike(reviewId, wasLiked);
  }
}
