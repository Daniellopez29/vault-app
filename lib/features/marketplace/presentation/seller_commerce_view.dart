import 'package:flutter/material.dart';
import '../../../core/dimens.dart';
import '../../../core/theme.dart';
import '../../business/presentation/my_business_tab.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router.dart';
import '../../subscription/domain/entities.dart';

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

/// Apartado "Mis productos en venta". Esqueleto: banner de suscripción +
/// espacio para la lista real (se conecta luego con su provider).
class _ProductsForSaleTab extends StatelessWidget {
  const _ProductsForSaleTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(VaultSpacing.md),
      children: [
        _ProductSubscriptionCard(
          onTap: () => context.push(
            AppRoutes.subscription,
            extra: SubscriptionType.product,
          ),
        ),
        const SizedBox(height: VaultSpacing.lg),
        // TEMPORAL: aquí va tu lista real de productos en venta.
        const Center(
          child: Padding(
            padding: EdgeInsets.all(VaultSpacing.xl),
            child: Text(
              "Aquí aparecerán tus productos en venta.",
              style: TextStyle(color: VaultColors.textSecondary),
            ),
          ),
        ),
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
