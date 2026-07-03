import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../domain/entities.dart';
import 'providers.dart';

class ProfileHeader extends StatelessWidget {
  final String email;
  final int totalArticles;
  final Map<String, int> categoryCounts;
  final String? fullName;

  const ProfileHeader({
    super.key,
    required this.email,
    required this.totalArticles,
    required this.categoryCounts,
    this.fullName,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final displayName = fullName?.isNotEmpty == true ? fullName! : email;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VaultColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Perfil de Usuario', style: tt.titleLarge),
                const SizedBox(height: 10),
                Text('Artículos Totales: $totalArticles', style: tt.titleMedium),
                const SizedBox(height: 4),
                if (categoryCounts.isEmpty)
                  Text('Aún no tienes artículos registrados', style: tt.bodyMedium)
                else
                  ...categoryCounts.entries.map(
                        (e) => Text('${e.key}: ${e.value}', style: tt.bodyMedium),
                  ),
              ],
            ),
          ),
          Column(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: VaultColors.primary.withValues(alpha: 0.1),
                child: Icon(Icons.person, size: 36, color: VaultColors.primary),
              ),
              const SizedBox(height: 8),
              Text(displayName, style: tt.titleMedium),
              Text(email, style: tt.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}

class AssetsBody extends StatelessWidget {
  final WidgetRef ref;
  final ProfileAssetsState state;

  const AssetsBody({super.key, required this.ref, required this.state});

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case ProfileAssetsStatus.initial:
      case ProfileAssetsStatus.loading:
        return const Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        );
      case ProfileAssetsStatus.error:
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(state.errorMessage ?? 'Error al cargar tus artículos'),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () =>
                    ref.read(profileAssetsControllerProvider.notifier).loadAssets(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        );
      case ProfileAssetsStatus.loaded:
        if (state.assets.isEmpty) return const EmptyAssetsView();
        return AssetsGrid(
          assets: state.assets,
          onDelete: (id) =>
              ref.read(profileAssetsControllerProvider.notifier).deleteAsset(id),
        );
    }
  }
}

class EmptyAssetsView extends StatelessWidget {
  const EmptyAssetsView({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: 56, color: VaultColors.textSecondary),
          const SizedBox(height: 12),
          Text(
            'Aún no has registrado ningún activo',
            textAlign: TextAlign.center,
            style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Usa el botón + para agregar tu primera pieza',
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
  final ValueChanged<String> onDelete;

  const AssetsGrid({super.key, required this.assets, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: assets.length,
      itemBuilder: (context, index) {
        final asset = assets[index];
        return AssetCard(asset: asset, onDelete: () => onDelete(asset.id));
      },
    );
  }
}

class AssetCard extends StatelessWidget {
  final AssetEntity asset;
  final VoidCallback onDelete;

  const AssetCard({super.key, required this.asset, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: VaultColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: Container(
                color: VaultColors.background,
                child: Center(
                  child: Icon(Icons.image_outlined, size: 36, color: VaultColors.textSecondary),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(asset.brand, style: tt.titleMedium?.copyWith(fontSize: 12)),
                Text(asset.name, style: tt.bodyLarge?.copyWith(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('Talla: ${asset.size}', style: tt.bodyMedium?.copyWith(fontSize: 10)),
                Text(asset.condition, style: tt.bodyMedium?.copyWith(fontSize: 10)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  onPressed: () {},
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 16),
                  onPressed: onDelete,
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined, size: 16),
                  onPressed: () {},
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}