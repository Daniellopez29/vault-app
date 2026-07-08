import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/dimens.dart';
import '../../../core/router.dart';
import '../../../core/theme.dart';
import '../../cart/domain/entities.dart';
import '../../cart/presentation/providers.dart';
import '../domain/entities.dart';
import 'providers.dart';
import 'widgets.dart';

class ShopTab extends ConsumerWidget {
  const ShopTab({super.key});

  void _addToCart(BuildContext context, WidgetRef ref, MarketplaceItemEntity item) {
    ref.read(cartControllerProvider.notifier).addItem(
      CartItemEntity(
        id: item.id,
        title: item.title,
        brand: item.brand,
        imageUrl: item.imageUrl,
        unitPrice: item.price,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.title} añadido al carrito')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(shopControllerProvider);

    switch (state.status) {
      case ShopStatus.initial:
      case ShopStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case ShopStatus.error:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(state.errorMessage ?? 'Error al cargar el Shop'),
              const SizedBox(height: VaultSpacing.md),
              TextButton(
                onPressed: () =>
                    ref.read(shopControllerProvider.notifier).loadShop(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        );

      case ShopStatus.loaded:
        return Scaffold(
          backgroundColor: VaultColors.background,
          floatingActionButton: FloatingActionButton(
            backgroundColor: VaultColors.primary,
            onPressed: () => context.push(AppRoutes.cart),
            child: Icon(
              Icons.shopping_cart_outlined,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () =>
                ref.read(shopControllerProvider.notifier).loadShop(),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      VaultSpacing.md,
                      VaultSpacing.md,
                      VaultSpacing.md,
                      VaultSpacing.xs,
                    ),
                    child: PromoCarousel(banners: state.banners),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(VaultSpacing.md),
                  sliver: SliverGrid(
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: VaultSpacing.md,
                      mainAxisSpacing: VaultSpacing.md,
                      mainAxisExtent: 255,
                    ),
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final item = state.items[index];
                        return MarketplaceCard(
                          item: item,
                          onCartTap: () => _addToCart(context, ref, item),
                        );
                      },
                      childCount: state.items.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }
}