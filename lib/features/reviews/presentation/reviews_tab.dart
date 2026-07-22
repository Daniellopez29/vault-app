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
      return const Center(child: Text('Inicia sesiÃ³n para ver tus reseÃ±as'));
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
              Text(state.errorMessage ?? 'Error al cargar tus reseÃ±as'),
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
                const Icon(Icons.star_outline,
                    size: VaultIconSize.xl, color: VaultColors.textSecondary),
                const SizedBox(height: VaultSpacing.lg),
                Text('Aun no tienes resenas', style: tt.titleLarge),
                const SizedBox(height: VaultSpacing.sm),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: VaultSpacing.xl),
                  child: Text(
                    'Cuando vendas un articulo o prestes un servicio, las '
                    'valoraciones que recibas apareceran aqui.',
                    textAlign: TextAlign.center,
                    style: tt.bodyMedium?.copyWith(color: VaultColors.textSecondary),
                  ),
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

