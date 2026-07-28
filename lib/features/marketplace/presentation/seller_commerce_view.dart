import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/dimens.dart';
import '../../../core/router.dart';
import '../../../core/theme.dart';
import '../../business/presentation/my_business_tab.dart';
import '../../subscription/domain/entities.dart';
import '../../profile/presentation/asset_widgets.dart';
import '../../profile/presentation/providers.dart';
import '../../ads/presentation/advertise_flow.dart';

/// Vista de comercio del vendedor. Contiene dos apartados:
/// 1) "En venta": sus productos publicados + suscripción para destacarlos.
/// 2) "Mi negocio": alta y administración del negocio.
/// Por ahora es el esqueleto visual; el contenido real de cada pestaña
/// se conecta después con sus providers.
class SellerCommerceView extends StatelessWidget {
  const SellerCommerceView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: VaultColors.background,
        appBar: AppBar(
          backgroundColor: VaultColors.background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          foregroundColor: VaultColors.textPrimary,
          title: const Text("Comercio"),
          bottom: const TabBar(
            labelColor: VaultColors.primary,
            unselectedLabelColor: VaultColors.textSecondary,
            indicatorColor: VaultColors.primary,
            tabs: [
              Tab(text: "En venta"),
              Tab(text: "Mi negocio"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ProductsForSaleTab(),
            MyBusinessTab(),
          ],
        ),
      ),
    );
  }
}

/// Apartado "Mis productos en venta": banner de suscripción + los activos
/// del usuario que tiene marcados como en venta (mismo estado que alimenta
/// el grid de "Mis artículos" en el Perfil, solo que filtrado).
class _ProductsForSaleTab extends ConsumerWidget {
  const _ProductsForSaleTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileAssetsControllerProvider);
    final forSale = state.assets.where((a) => a.isForSale).toList();

    return ListView(
      padding: const EdgeInsets.all(VaultSpacing.md),
      children: [
        _ProductSubscriptionCard(
          onTap: () => startAdvertiseFlow(context, ref, type: SubscriptionType.product),
        ),
        const SizedBox(height: VaultSpacing.sm),
        TextButton.icon(
          onPressed: () => context.push(AppRoutes.myAds),
          icon: const Icon(Icons.campaign_outlined),
          label: const Text('Ver mis anuncios'),
        ),
        const SizedBox(height: VaultSpacing.md),
        switch (state.status) {
          ProfileAssetsStatus.initial ||
          ProfileAssetsStatus.loading =>
            const Center(
              child: Padding(
                padding: EdgeInsets.all(VaultSpacing.xl),
                child: CircularProgressIndicator(),
              ),
            ),
          ProfileAssetsStatus.error => Center(
              child: Padding(
                padding: const EdgeInsets.all(VaultSpacing.xl),
                child: Text(
                  state.errorMessage ?? "Error al cargar tus productos",
                  style: const TextStyle(color: VaultColors.textSecondary),
                ),
              ),
            ),
          ProfileAssetsStatus.loaded => forSale.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(VaultSpacing.xl),
                    child: Text(
                      "Aún no has puesto ningún artículo en venta.\n"
                      "Márcalo desde tu Perfil con el ícono de etiqueta.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: VaultColors.textSecondary),
                    ),
                  ),
                )
              : AssetsGrid(assets: forSale),
        },
      ],
    );
  }
}



/// Card de suscripción de productos, arriba de la lista de "En venta".
/// Da al vendedor acceso directo a destacar sus productos desde donde los
/// administra. Fondo accent (señal de compra); texto desde SubscriptionCopy
/// (dominio), no hardcodeado. Navega a los planes de tipo producto.
class _ProductSubscriptionCard extends StatelessWidget {
  final VoidCallback onTap;

  const _ProductSubscriptionCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Material(
      color: VaultColors.accent,
      borderRadius: BorderRadius.circular(VaultRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(VaultRadius.card),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(VaultSpacing.lg),
          child: Row(
            children: [
              const Icon(Icons.rocket_launch_outlined,
                  color: Colors.white, size: VaultIconSize.lg),
              const SizedBox(width: VaultSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      SubscriptionCopy.titleFor(SubscriptionType.product),
                      style: tt.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: VaultSpacing.xs),
                    Text(
                      SubscriptionCopy.subtitleFor(SubscriptionType.product),
                      style: tt.bodySmall?.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
