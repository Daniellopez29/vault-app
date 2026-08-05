import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/dimens.dart';
import '../../../core/router.dart';
import '../../../core/theme.dart';
import '../../../core/widgets/skeleton.dart';
import '../../auth/presentation/providers.dart';
import '../../chat/presentation/chat_page.dart';
import '../../marketplace/presentation/item_image.dart';
import '../domain/entities.dart';
import 'providers.dart';

/// Directorio de negocios registrados en la plataforma.
/// Solo lectura: muestra los negocios que otros usuarios dieron de alta.
class BusinessesTab extends ConsumerWidget {
  const BusinessesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessesAsync = ref.watch(allBusinessesProvider);

    return Scaffold(
      backgroundColor: VaultColors.background,
      body: businessesAsync.when(
        loading: () => const BusinessesSkeleton(),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(VaultSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'No se pudieron cargar los negocios',
                  style: TextStyle(color: VaultColors.textSecondary),
                ),
                const SizedBox(height: VaultSpacing.md),
                ElevatedButton(
                  onPressed: () => ref.invalidate(allBusinessesProvider),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
        data: (businesses) {
          if (businesses.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(VaultSpacing.xl),
                child: Text(
                  'Aún no hay negocios registrados.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: VaultColors.textSecondary),
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(allBusinessesProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(VaultSpacing.md),
              itemCount: businesses.length,
              itemBuilder: (context, index) {
                return _BusinessCard(business: businesses[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

/// Tarjeta de un negocio. La entidad no tiene imágenes todavía (el backend
/// no las expone), por eso se representa con un ícono y sus datos.
class _BusinessCard extends ConsumerWidget {
  final BusinessEntity business;

  const _BusinessCard({required this.business});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final currentUserId = ref.watch(authControllerProvider).user?.id;
    final isSelf = currentUserId != null && currentUserId == business.userId;

    return Container(
      margin: const EdgeInsets.only(bottom: VaultSpacing.md),
      padding: const EdgeInsets.all(VaultSpacing.md),
      decoration: BoxDecoration(
        color: VaultColors.surface,
        borderRadius: VaultRadius.cardBorder,
        border: Border.all(color: VaultColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(VaultRadius.sm),
            child: SizedBox(
              width: 52,
              height: 52,
              child: business.photos.isNotEmpty
                  ? ItemImage(imageUrl: business.photos.first.url)
                  : Container(
                      color: VaultColors.background,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.storefront_outlined,
                        color: VaultColors.primary,
                        size: VaultIconSize.lg,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: VaultSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        business.name,
                        style: tt.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (business.isVerified) ...[
                      const SizedBox(width: VaultSpacing.xs),
                      Icon(
                        Icons.verified_user,
                        size: VaultIconSize.sm,
                        color: VaultColors.accent,
                      ),
                    ],
                  ],
                ),
                Text(
                  business.types.join(' · '),
                  style: tt.labelSmall?.copyWith(
                    color: VaultColors.textSecondary,
                  ),
                ),
                if (business.description.isNotEmpty) ...[
                  const SizedBox(height: VaultSpacing.xs),
                  Text(
                    business.description,
                    style: tt.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (business.location.isNotEmpty) ...[
                  const SizedBox(height: VaultSpacing.xs),
                  Row(
                    children: [
                      Icon(
                        Icons.place_outlined,
                        size: VaultIconSize.sm,
                        color: VaultColors.textSecondary,
                      ),
                      const SizedBox(width: VaultSpacing.xs),
                      Expanded(
                        child: Text(
                          business.location,
                          style: tt.labelSmall?.copyWith(
                            color: VaultColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                if (!isSelf) ...[
                  const SizedBox(height: VaultSpacing.xs),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => context.push(
                        AppRoutes.chat,
                        extra: ChatPageArgs(
                          recipientId: business.userId,
                          recipientName: business.name,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: VaultColors.primary,
                        padding: EdgeInsets.zero,
                      ),
                      icon: const Icon(
                        Icons.chat_bubble_outline,
                        size: VaultIconSize.sm,
                      ),
                      label: const Text('Contactar'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Esqueleto de carga del directorio de negocios: imita las tarjetas de lista.
class BusinessesSkeleton extends StatelessWidget {
  const BusinessesSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(VaultSpacing.md),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      itemBuilder: (context, index) => const _BusinessCardSkeleton(),
    );
  }
}

class _BusinessCardSkeleton extends StatelessWidget {
  const _BusinessCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: VaultSpacing.md),
      padding: const EdgeInsets.all(VaultSpacing.md),
      decoration: BoxDecoration(
        color: VaultColors.surface,
        borderRadius: VaultRadius.cardBorder,
        border: Border.all(color: VaultColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(width: 52, height: 52),
          const SizedBox(width: VaultSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonLine(widthFactor: 0.5, height: 15),
                SizedBox(height: VaultSpacing.xs),
                SkeletonLine(widthFactor: 0.25, height: 10),
                SizedBox(height: VaultSpacing.sm),
                SkeletonLine(widthFactor: 0.9),
                SizedBox(height: VaultSpacing.xs),
                SkeletonLine(widthFactor: 0.4, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
