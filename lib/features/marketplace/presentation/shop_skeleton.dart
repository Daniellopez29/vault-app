import 'package:flutter/material.dart';
import '../../../core/dimens.dart';
import '../../../core/theme.dart';
import '../../../core/widgets/skeleton.dart';

/// Esqueleto de carga del Shop: imita el carrusel y el grid de productos,
/// para que la transición al contenido real no salte.
class ShopSkeleton extends StatelessWidget {
  const ShopSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(VaultSpacing.md),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        const SkeletonBox(height: 120, radius: VaultRadius.card),
        const SizedBox(height: VaultSpacing.lg),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: VaultSpacing.md,
            mainAxisSpacing: VaultSpacing.md,
            mainAxisExtent: 290,
          ),
          itemBuilder: (context, index) => const _ProductCardSkeleton(),
        ),
      ],
    );
  }
}

class _ProductCardSkeleton extends StatelessWidget {
  const _ProductCardSkeleton();

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: VaultColors.surface,
        borderRadius: VaultRadius.cardBorder,
        border: Border.all(color: VaultColors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(height: 120, radius: 0),
          Padding(
            padding: const EdgeInsets.all(VaultSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonLine(widthFactor: 0.3, height: 14),
                SizedBox(height: VaultSpacing.sm),
                SkeletonLine(widthFactor: 0.5),
                SizedBox(height: VaultSpacing.xs),
                SkeletonLine(widthFactor: 0.8),
                SizedBox(height: VaultSpacing.sm),
                SkeletonLine(widthFactor: 0.6, height: 10),
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
