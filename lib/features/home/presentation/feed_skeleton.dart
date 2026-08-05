import 'package:flutter/material.dart';
import '../../../core/dimens.dart';
import '../../../core/theme.dart';
import '../../../core/widgets/skeleton.dart';

/// Esqueleto de carga del Feed: imita las tarjetas de publicación.
class FeedSkeleton extends StatelessWidget {
  const FeedSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(VaultSpacing.md),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) => const Padding(
        padding: EdgeInsets.only(bottom: VaultSpacing.lg),
        child: _PostCardSkeleton(),
      ),
    );
  }
}

class _PostCardSkeleton extends StatelessWidget {
  const _PostCardSkeleton();

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
          const AspectRatio(
            aspectRatio: 16 / 11,
            child: SkeletonBox(height: double.infinity, radius: 0),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: VaultSpacing.lg,
              vertical: VaultSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonLine(widthFactor: 0.55, height: 16),
                SizedBox(height: VaultSpacing.xs),
                SkeletonLine(widthFactor: 0.25, height: 11),
                SizedBox(height: VaultSpacing.md),
                SkeletonLine(widthFactor: 0.95),
                SizedBox(height: VaultSpacing.xs),
                SkeletonLine(widthFactor: 0.7),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
