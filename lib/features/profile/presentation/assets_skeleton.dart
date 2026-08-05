import 'package:flutter/material.dart';
import '../../../core/dimens.dart';
import '../../../core/theme.dart';
import '../../../core/widgets/skeleton.dart';

/// Esqueleto de carga del inventario de activos del perfil.
class AssetsSkeleton extends StatelessWidget {
  const AssetsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(VaultSpacing.md),
      itemCount: 4,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: VaultSpacing.md,
        mainAxisSpacing: VaultSpacing.md,
        mainAxisExtent: 230,
      ),
      itemBuilder: (context, index) => const _AssetCardSkeleton(),
    );
  }
}

class _AssetCardSkeleton extends StatelessWidget {
  const _AssetCardSkeleton();

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: VaultColors.surface,
        borderRadius: VaultRadius.cardBorder,
        boxShadow: VaultShadows.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: SkeletonBox(height: double.infinity, radius: 0),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: VaultSpacing.sm,
              vertical: VaultSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonLine(widthFactor: 0.45, height: 12),
                SizedBox(height: VaultSpacing.xs),
                SkeletonLine(widthFactor: 0.75, height: 11),
                SizedBox(height: VaultSpacing.xs),
                SkeletonLine(widthFactor: 0.35, height: 9),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
