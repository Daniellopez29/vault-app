import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/dimens.dart';
import '../../../core/theme.dart';
import '../../auth/presentation/providers.dart';
import 'providers.dart';

class ReviewsTab extends ConsumerWidget {
  const ReviewsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authControllerProvider).user?.id;
    if (userId == null) {
      return const Center(child: Text('Inicia sesión para ver tus reseñas'));
    }

    final state = ref.watch(reviewsControllerProvider(userId));
    final tt = Theme.of(context).textTheme;

    switch (state.status) {
      case ReviewsStatus.initial:
      case ReviewsStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case ReviewsStatus.error:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(state.errorMessage ?? 'Error al cargar tus reseñas'),
              const SizedBox(height: VaultSpacing.md),
              TextButton(
                onPressed: () =>
                    ref.read(reviewsControllerProvider(userId).notifier).loadReviews(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        );
      case ReviewsStatus.loaded:
        if (state.reviews.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star_outline, size: 64, color: VaultColors.textSecondary),
                const SizedBox(height: 16),
                Text('Mis Reseñas', style: tt.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  'Aquí verás las valoraciones\nque tus clientes te han dejado',
                  textAlign: TextAlign.center,
                  style: tt.bodyMedium,
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () => ref.read(reviewsControllerProvider(userId).notifier).loadReviews(),
          child: ListView.separated(
            padding: const EdgeInsets.all(VaultSpacing.md),
            itemCount: state.reviews.length,
            separatorBuilder: (_, _) => const SizedBox(height: VaultSpacing.sm),
            itemBuilder: (context, index) {
              final review = state.reviews[index];
              return Container(
                padding: const EdgeInsets.all(VaultSpacing.md),
                decoration: BoxDecoration(
                  color: VaultColors.surface,
                  borderRadius: VaultRadius.cardBorder,
                  boxShadow: VaultShadows.card,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(review.authorName, style: tt.titleMedium),
                        Text(review.timeAgo, style: tt.bodySmall),
                      ],
                    ),
                    const SizedBox(height: VaultSpacing.xs),
                    Text(review.content, style: tt.bodyLarge),
                    const SizedBox(height: VaultSpacing.xs),
                    GestureDetector(
                      onTap: () => ref
                          .read(reviewsControllerProvider(userId).notifier)
                          .toggleLike(review.id),
                      child: Row(
                        children: [
                          Icon(
                            review.isLiked ? Icons.favorite : Icons.favorite_border,
                            size: VaultIconSize.sm,
                            color: review.isLiked ? VaultColors.error : VaultColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text('${review.likesCount}', style: tt.labelSmall),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
    }
  }
}
