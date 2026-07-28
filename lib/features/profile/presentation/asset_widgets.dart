import 'assets_skeleton.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/dimens.dart';
import '../../../core/theme.dart';
import '../../marketplace/presentation/item_image.dart';
import '../domain/entities.dart';
import 'asset_sheets.dart';
import 'providers.dart';
class AssetsBody extends StatelessWidget {
  final WidgetRef ref;
  final ProfileAssetsState state;

  const AssetsBody({super.key, required this.ref, required this.state});

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case ProfileAssetsStatus.initial:
      case ProfileAssetsStatus.loading:
        return const AssetsSkeleton();
      case ProfileAssetsStatus.error:
        return Padding(
          padding: const EdgeInsets.all(VaultSpacing.xl),
          child: Column(
            children: [
              Text(state.errorMessage ?? 'Error al cargar tus artículos'),
              const SizedBox(height: VaultSpacing.md),
              TextButton(
                onPressed: () => ref
                    .read(profileAssetsControllerProvider.notifier)
                    .loadAssets(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        );
      case ProfileAssetsStatus.loaded:
        if (state.assets.isEmpty) return const EmptyAssetsView();
        return AssetsGrid(assets: state.assets);
    }
  }
}

class EmptyAssetsView extends StatelessWidget {
  const EmptyAssetsView({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: VaultSpacing.xxl, horizontal: VaultSpacing.xl),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 56, color: VaultColors.textSecondary),
          const SizedBox(height: VaultSpacing.md),
          Text(
            'Aún no has registrado ningún activo',
            textAlign: TextAlign.center,
            style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: VaultSpacing.xs),
          Text(
            'Usa el botón "Agregar activo" para registrar tu primera pieza',
            textAlign: TextAlign.center,
            style: tt.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class AssetsGrid extends StatelessWidget {
  final List<AssetEntity> assets;

  const AssetsGrid({super.key, required this.assets});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(VaultSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: VaultSpacing.md,
        crossAxisSpacing: VaultSpacing.md,
        childAspectRatio: 0.66,
      ),
      itemCount: assets.length,
      itemBuilder: (context, index) => AssetCard(asset: assets[index]),
    );
  }
}

class AssetCard extends ConsumerWidget {
  final AssetEntity asset;

  const AssetCard({super.key, required this.asset});

  void _openPublishSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: VaultColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(VaultRadius.card)),
      ),
      builder: (_) => PublishAssetSheet(asset: asset),
    );
  }

  void _openSellSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: VaultColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(VaultRadius.card)),
      ),
      builder: (_) => SellAssetSheet(asset: asset),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final notifier = ref.read(profileAssetsControllerProvider.notifier);

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
          Expanded(
              child: GestureDetector(
                onTap: () => context.push(AppRoutes.assetDetail, extra: asset),
                child: Stack(
              children: [
                Positioned.fill(
                  child: ItemImage(imageUrl: asset.imageUrl),
                ),
                if (asset.isPublished)
                  Positioned(
                    top: VaultSpacing.xs,
                    left: VaultSpacing.xs,
                    child: _StatusBadge(
                      label: 'Publicado',
                      color: VaultColors.primary,
                    ),
                  ),
                if (asset.isForSale)
                  Positioned(
                    top: VaultSpacing.xs,
                    right: VaultSpacing.xs,
                    child: _StatusBadge(
                      label: '\$${asset.salePrice?.toStringAsFixed(0) ?? ''}',
                      color: VaultColors.accent,
                    ),
                  ),
                Positioned(
                  bottom: VaultSpacing.xs,
                  left: VaultSpacing.xs,
                  child: _StatusBadge(
                    label: asset.isVerified ? 'Verificado' : 'Verificando...',
                    color: asset.isVerified ? VaultColors.success : VaultColors.textSecondary,
                  ),
                ),
              ],
            ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: VaultSpacing.sm, vertical: VaultSpacing.xs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(asset.brand, style: tt.titleMedium?.copyWith(fontSize: 12)),
                Text(asset.name,
                    style: tt.bodyLarge?.copyWith(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text('Talla: ${asset.size}',
                    style: tt.bodyMedium?.copyWith(fontSize: 10)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: VaultSpacing.xs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _CardAction(
                  icon: asset.isPublished ? Icons.public : Icons.public_off,
                  color: asset.isPublished
                      ? VaultColors.primary
                      : VaultColors.textSecondary,
                  onTap: () => _openPublishSheet(context),
                ),
                _CardAction(
                  icon: asset.isForSale ? Icons.sell : Icons.sell_outlined,
                  color: asset.isForSale
                      ? VaultColors.accent
                      : VaultColors.textSecondary,
                  onTap: () => _openSellSheet(context),
                ),
                _CardAction(
                  icon: Icons.delete_outline,
                  color: VaultColors.textSecondary,
                  onTap: () => notifier.deleteAsset(asset.id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge de estado (Publicado / En venta) sobre la imagen del activo.
class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: VaultSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(VaultRadius.sm),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Botón de acción de la card, con densidad compacta.
class _CardAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CardAction({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: VaultIconSize.sm, color: color),
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }
}

