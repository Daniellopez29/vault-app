import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/dimens.dart';
import '../../../core/router.dart';
import '../../../core/theme.dart';
import '../../business/domain/entities.dart';
import '../../profile/domain/entities.dart';
import '../../profile/presentation/providers.dart';
import '../../subscription/domain/entities.dart';
import '../../subscription/presentation/providers.dart';
import '../domain/entities.dart';
import 'providers.dart';

/// Punto de entrada único de "Anunciar": si ya hay una suscripción activa,
/// deja elegir qué anunciar y crea el anuncio real (`POST /ads`); si no,
/// manda primero a comprar un plan -- igual que antes de este cambio, salvo
/// que ahora sí termina en un anuncio real en vez de no hacer nada más.
Future<void> startAdvertiseFlow(
  BuildContext context,
  WidgetRef ref, {
  required SubscriptionType type,
  BusinessEntity? business,
}) async {
  final subscriptionState = ref.read(subscriptionStatusControllerProvider);
  final hasActiveSubscription = subscriptionState.subscription?.isActive ?? false;

  if (!hasActiveSubscription) {
    if (!context.mounted) return;
    context.push(AppRoutes.subscription, extra: type);
    return;
  }

  if (type == SubscriptionType.business) {
    if (business == null) return;
    await _createAd(
      context,
      ref,
      title: business.name,
      description: business.description,
      imageUrl: business.photos.firstOrNull?.url ?? '',
      targetId: business.id,
    );
    return;
  }

  final forSale = ref
      .read(profileAssetsControllerProvider)
      .assets
      .where((a) => a.isForSale)
      .toList();

  if (forSale.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pon al menos un artículo en venta para poder anunciarlo')),
    );
    return;
  }

  final chosen = await showModalBottomSheet<AssetEntity>(
    context: context,
    isScrollControlled: true,
    backgroundColor: VaultColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(VaultRadius.card)),
    ),
    builder: (_) => _ChooseAssetSheet(assets: forSale),
  );
  if (chosen == null || !context.mounted) return;

  await _createAd(
    context,
    ref,
    title: '${chosen.brand} ${chosen.name}',
    description: chosen.notes ?? '',
    imageUrl: chosen.imageUrl,
    targetId: chosen.id,
  );
}

Future<void> _createAd(
  BuildContext context,
  WidgetRef ref, {
  required String title,
  required String description,
  required String imageUrl,
  required String targetId,
}) async {
  final result = await ref.read(createAdUseCaseProvider)(CreateAdParams(
    title: title,
    description: description,
    imageUrl: imageUrl,
    targetSection: AdSection.marketplace,
    targetId: targetId,
  ));

  if (!context.mounted) return;
  result.fold(
    (failure) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(failure.message)),
    ),
    (_) {
      // El carrusel y el grid del Shop leen esta misma instancia -- se
      // refrescan solos en cuanto termina la carga, sin pull to refresh.
      ref.read(activeAdsControllerProvider(AdSection.marketplace).notifier).load();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tu anuncio ya está activo')),
      );
    },
  );
}

class _ChooseAssetSheet extends StatelessWidget {
  final List<AssetEntity> assets;

  const _ChooseAssetSheet({required this.assets});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(VaultSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('¿Qué quieres anunciar?', style: tt.titleMedium),
            const SizedBox(height: VaultSpacing.sm),
            Text(
              'Aparecerá en el carrusel y en el catálogo del Shop.',
              style: tt.bodySmall?.copyWith(color: VaultColors.textSecondary),
            ),
            const SizedBox(height: VaultSpacing.md),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: assets.length,
                separatorBuilder: (_, _) => const SizedBox(height: VaultSpacing.sm),
                itemBuilder: (context, index) {
                  final asset = assets[index];
                  return ListTile(
                    tileColor: VaultColors.background,
                    shape: RoundedRectangleBorder(borderRadius: VaultRadius.cardBorder),
                    leading: ClipRRect(
                      borderRadius: VaultRadius.cardBorder,
                      child: Image.network(
                        asset.imageUrl,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: 44,
                          height: 44,
                          color: VaultColors.surface,
                          child: const Icon(Icons.image_not_supported_outlined),
                        ),
                      ),
                    ),
                    title: Text(asset.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(asset.brand),
                    onTap: () => Navigator.of(context).pop(asset),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
