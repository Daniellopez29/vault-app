import 'assets_skeleton.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/dimens.dart';
import '../../../core/theme.dart';
import '../../marketplace/presentation/item_image.dart';
import '../../servicerequests/domain/entities.dart';
import '../../servicerequests/presentation/providers.dart';
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

class AssetsGrid extends ConsumerWidget {
  final List<AssetEntity> assets;

  const AssetsGrid({super.key, required this.assets});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Un artículo "terminado" (el negocio ya lo dejó listo, falta que el
    // dueño confirme que lo recibió de vuelta) se pasa al frente de la
    // cuadrícula -- es la acción pendiente más importante, no debería
    // perderse scrolleando entre el resto de los activos.
    final requestsByAsset = <String, ServiceRequestEntity>{};
    for (final r in ref.watch(myServiceRequestsControllerProvider).requests) {
      if (r.status != ServiceRequestStatus.confirmado) {
        requestsByAsset.putIfAbsent(r.assetId, () => r);
      }
    }

    final ordered = [...assets];
    ordered.sort((a, b) {
      final aReady = requestsByAsset[a.id]?.status == ServiceRequestStatus.terminado;
      final bReady = requestsByAsset[b.id]?.status == ServiceRequestStatus.terminado;
      if (aReady == bReady) return 0;
      return aReady ? -1 : 1;
    });

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
      itemCount: ordered.length,
      itemBuilder: (context, index) => AssetCard(
        asset: ordered[index],
        serviceRequest: requestsByAsset[ordered[index].id],
      ),
    );
  }
}

class AssetCard extends ConsumerWidget {
  final AssetEntity asset;

  /// Solicitud de servicio/reparación activa para este activo (si hay una),
  /// ver `AssetsGrid`.
  final ServiceRequestEntity? serviceRequest;

  const AssetCard({super.key, required this.asset, this.serviceRequest});

  (String, Color)? get _serviceStatusInfo {
    switch (serviceRequest?.status) {
      case ServiceRequestStatus.pendienteAceptacion:
        return ('Enviado', VaultColors.textSecondary);
      case ServiceRequestStatus.enEspera:
        return ('En espera', VaultColors.accent);
      case ServiceRequestStatus.enServicio:
        return (
          serviceRequest!.type == ServiceRequestType.reparacion ? 'En reparación' : 'En servicio',
          VaultColors.primary,
        );
      case ServiceRequestStatus.terminado:
        return ('Listo', VaultColors.success);
      default:
        return null;
    }
  }

  Future<void> _confirmReceipt(BuildContext context, WidgetRef ref) async {
    final request = serviceRequest;
    if (request == null) return;
    final ok = await ref.read(myServiceRequestsControllerProvider.notifier).confirm(request.id);
    if (!context.mounted) return;
    if (!ok) {
      final error = ref.read(myServiceRequestsControllerProvider).errorMessage ??
          'No se pudo confirmar la recepción';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

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

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar activo'),
        content: Text(
          '¿Estás seguro que deseas eliminar "${asset.name}"? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(profileAssetsControllerProvider.notifier).deleteAsset(asset.id);
            },
            child: Text('Eliminar', style: TextStyle(color: VaultColors.error)),
          ),
        ],
      ),
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
                if (serviceRequest?.status == ServiceRequestStatus.terminado)
                  Positioned.fill(
                    child: Container(color: Colors.black.withValues(alpha: 0.45)),
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
                if (_serviceStatusInfo != null)
                  Positioned(
                    bottom: VaultSpacing.xs,
                    right: VaultSpacing.xs,
                    child: _StatusBadge(
                      label: _serviceStatusInfo!.$1,
                      color: _serviceStatusInfo!.$2,
                    ),
                  ),
                Positioned(
                  bottom: VaultSpacing.xs,
                  left: VaultSpacing.xs,
                  // Mismo ícono que usa el marketplace público para
                  // productos verificados (ver marketplace_card.dart) --
                  // lenguaje visual consistente entre las dos vistas.
                  child: Icon(
                    asset.isVerified ? Icons.verified_user : Icons.hourglass_top,
                    color: asset.isVerified ? VaultColors.accent : VaultColors.textSecondary,
                    size: VaultIconSize.md,
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
                  onTap: () => _confirmDelete(context, ref),
                ),
              ],
            ),
          ),
          if (serviceRequest?.status == ServiceRequestStatus.terminado)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  VaultSpacing.sm, 0, VaultSpacing.sm, VaultSpacing.sm),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _confirmReceipt(context, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VaultColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    visualDensity: VisualDensity.compact,
                    textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  icon: const Icon(Icons.check_circle_outline, size: 14),
                  label: const Text('Confirmar recepción'),
                ),
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
  final String? tooltip;

  const _CardAction({
    required this.icon,
    required this.color,
    required this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: VaultIconSize.sm, color: color),
      onPressed: onTap,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }
}

