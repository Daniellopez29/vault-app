import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/providers.dart';
import '../domain/entities.dart';
import 'providers.dart';

const _kDark = Color(0xFF2D2D3A);

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final assetsState = ref.watch(profileAssetsControllerProvider);
    final email = authState.user?.email ?? '';

    return RefreshIndicator(
      onRefresh: () => ref.read(profileAssetsControllerProvider.notifier).loadAssets(),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _ProfileHeader(
              email: email,
              fullName: authState.user?.fullName,
              totalArticles: assetsState.totalArticles,
              categoryCounts: assetsState.categoryCounts,
            ),
          ),
          SliverToBoxAdapter(child: _buildBody(context, ref, assetsState)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, ProfileAssetsState state) {
    switch (state.status) {
      case ProfileAssetsStatus.initial:
      case ProfileAssetsStatus.loading:
        return const Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator(color: _kDark)),
        );
      case ProfileAssetsStatus.error:
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(state.errorMessage ?? 'Error al cargar tus artículos'),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => ref.read(profileAssetsControllerProvider.notifier).loadAssets(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        );
      case ProfileAssetsStatus.loaded:
        if (state.assets.isEmpty) {
          return const _EmptyAssetsView();
        }
        return _AssetsGrid(
          assets: state.assets,
          onDelete: (id) => ref.read(profileAssetsControllerProvider.notifier).deleteAsset(id),
        );
    }
  }
}

class _ProfileHeader extends StatelessWidget {
  final String email;
  final int totalArticles;
  final Map<String, int> categoryCounts;
  final String? fullName;

  const _ProfileHeader({
    required this.email,
    required this.totalArticles,
    required this.categoryCounts,
    this.fullName,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = fullName?.isNotEmpty == true ? fullName! : email;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Perfil de Usuario',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                Text('Artículos Totales: $totalArticles',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                if (categoryCounts.isEmpty)
                  Text('Aún no tienes artículos registrados',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600))
                else
                  ...categoryCounts.entries.map(
                        (e) => Text('${e.key}: ${e.value}', style: const TextStyle(fontSize: 13)),
                  ),
              ],
            ),
          ),
          Column(
            children: [
              const CircleAvatar(
                radius: 36,
                backgroundColor: Color(0xFFE8F5E9),
                child: Icon(Icons.person, size: 36, color: _kDark),
              ),
              const SizedBox(height: 8),
              Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(email, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyAssetsView extends StatelessWidget {
  const _EmptyAssetsView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: 56, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'Aún no has registrado ningún activo',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Usa el botón + para agregar tu primera pieza',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _AssetsGrid extends StatelessWidget {
  final List<AssetEntity> assets;
  final ValueChanged<String> onDelete;

  const _AssetsGrid({required this.assets, required this.onDelete});

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
        return _AssetCard(asset: asset, onDelete: () => onDelete(asset.id));
      },
    );
  }
}

class _AssetCard extends StatelessWidget {
  final AssetEntity asset;
  final VoidCallback onDelete;

  const _AssetCard({required this.asset, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.image_outlined, size: 36, color: Colors.grey),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(asset.brand, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Text(asset.name, style: const TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('Talla: ${asset.size}', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                Text(asset.condition, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
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