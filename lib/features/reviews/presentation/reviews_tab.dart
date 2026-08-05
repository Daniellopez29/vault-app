import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/dimens.dart';
import '../../../core/theme.dart';
import '../../auth/presentation/providers.dart';
import 'providers.dart';

class ReviewsTab extends ConsumerWidget {
  /// Si se pasa, muestra las reseñas de ese proveedor (p.ej. el vendedor de
  /// un producto, siempre de solo lectura -- publicarlas solo se puede
  /// desde "Mis pedidos" tras una compra confirmada, ver
  /// `WriteReviewDialog`). Si se omite, muestra las reseñas del usuario
  /// autenticado (pestaña "Reseñas" del propio perfil).
  final String? providerId;

  /// true cuando se embebe dentro de otra lista (p.ej. el detalle de un
  /// producto) -- evita el error de "alto no acotado" de un ListView
  /// dentro de otro ListView.
  final bool shrinkWrap;

  const ReviewsTab({super.key, this.providerId, this.shrinkWrap = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveProviderId =
        providerId ?? ref.watch(authControllerProvider).user?.id;
    if (effectiveProviderId == null) {
      return const Center(child: Text('Inicia sesión para ver tus reseñas'));
    }

    final state = ref.watch(reviewsControllerProvider(effectiveProviderId));
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
                onPressed: () => ref
                    .read(
                      reviewsControllerProvider(effectiveProviderId).notifier,
                    )
                    .loadReviews(),
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
                Icon(
                  Icons.star_outline,
                  size: VaultIconSize.xl,
                  color: VaultColors.textSecondary,
                ),
                const SizedBox(height: VaultSpacing.lg),
                Text(
                  providerId != null
                      ? 'Aún no tiene reseñas'
                      : 'Aún no tienes reseñas',
                  style: tt.titleLarge,
                ),
                const SizedBox(height: VaultSpacing.sm),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: VaultSpacing.xl,
                  ),
                  child: Text(
                    providerId != null
                        ? 'Cuando reciba una reseña de un comprador, aparecerá aquí.'
                        : 'Cuando vendas un artículo o prestes un servicio, las '
                              'valoraciones que recibas aparecerán aquí.',
                    textAlign: TextAlign.center,
                    style: tt.bodyMedium?.copyWith(
                      color: VaultColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () => ref
              .read(reviewsControllerProvider(effectiveProviderId).notifier)
              .loadReviews(),
          child: ListView.separated(
            padding: const EdgeInsets.all(VaultSpacing.md),
            shrinkWrap: shrinkWrap,
            physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
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
                          .read(
                            reviewsControllerProvider(
                              effectiveProviderId,
                            ).notifier,
                          )
                          .toggleLike(review.id),
                      child: Row(
                        children: [
                          Icon(
                            review.isLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: VaultIconSize.sm,
                            color: review.isLiked
                                ? VaultColors.error
                                : VaultColors.textSecondary,
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
