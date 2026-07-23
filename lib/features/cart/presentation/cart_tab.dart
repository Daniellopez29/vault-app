import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/dimens.dart';
import '../../../core/router.dart';
import '../../../core/theme.dart';
import 'providers.dart';
import 'widgets.dart';

class CartTab extends ConsumerWidget {
  const CartTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cartControllerProvider);

    switch (state.status) {
      case CartStatus.initial:
      case CartStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case CartStatus.error:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(state.errorMessage ?? 'Error al cargar el carrito'),
              const SizedBox(height: VaultSpacing.md),
              TextButton(
                onPressed: () =>
                    ref.read(cartControllerProvider.notifier).loadCart(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        );

      case CartStatus.loaded:
        if (state.isEmpty) {
          return const _EmptyCart();
        }
        return _CartContent(state: state);
    }
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    // Mismo Scaffold (fondo + AppBar) que _CartContent -- para que el marco
    // de la pantalla no cambie entre carrito vacío y con artículos, solo el
    // contenido del cuerpo.
    return Scaffold(
      backgroundColor: VaultColors.background,
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: VaultIconSize.xl,
              color: VaultColors.textSecondary,
            ),
            const SizedBox(height: VaultSpacing.md),
            Text('Tu carrito está vacío', style: tt.titleLarge),
            const SizedBox(height: VaultSpacing.xs),
            Text(
              'Agrega activos desde el Shop para verlos aquí',
              style: tt.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CartContent extends ConsumerWidget {
  final CartState state;

  const _CartContent({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final summary = state.summary;

    return Scaffold(
      backgroundColor: VaultColors.background,
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: VaultSpacing.lg,
                vertical: VaultSpacing.sm,
              ),
              itemCount: state.items.length,
              separatorBuilder: (_, _) => Divider(color: VaultColors.divider),
              itemBuilder: (context, index) {
                final item = state.items[index];
                return CartItemRow(
                  item: item,
                  onRemove: () =>
                      ref.read(cartControllerProvider.notifier).removeItem(item.id),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(VaultSpacing.lg),
            decoration: BoxDecoration(
              color: VaultColors.surface,
              border: Border(top: BorderSide(color: VaultColors.divider)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('TOTAL', style: tt.titleLarge),
                      Text(
                        '\$${summary.total.toStringAsFixed(0)}',
                        style: tt.headlineMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: VaultSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => context.push(AppRoutes.checkoutAddress),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: VaultColors.accent,
                        side: const BorderSide(color: VaultColors.accent),
                      ),
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Proceder al Pago'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}