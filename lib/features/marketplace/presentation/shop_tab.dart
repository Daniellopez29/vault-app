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
import '../../../core/widgets/search_header.dart';
import 'shop_skeleton.dart';
import 'marketplace_card.dart';
import 'promo_carousel.dart';

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
      SnackBar(content: Text("${item.title} anadido al carrito")),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(shopControllerProvider);

    switch (state.status) {
      case ShopStatus.initial:
      case ShopStatus.loading:
        return const Scaffold(
          backgroundColor: VaultColors.background,
          body: ShopSkeleton(),
        );

      case ShopStatus.error:
        return Scaffold(
          backgroundColor: VaultColors.background,
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.errorMessage ?? "Error al cargar el Shop"),
                const SizedBox(height: VaultSpacing.md),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(shopControllerProvider.notifier).loadShop(),
                  child: const Text("Reintentar"),
                ),
              ],
            ),
          ),
        );

      case ShopStatus.loaded:
        final controller = ref.read(shopControllerProvider.notifier);
        final isSearching = state.searchQuery.trim().isNotEmpty;

        return Scaffold(
          backgroundColor: VaultColors.background,
          floatingActionButton: FloatingActionButton(
            heroTag: 'shop_fab',
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
                VaultSearchHeader(
                  query: state.searchQuery,
                  hintText: 'Buscar productos',
                  onQueryChanged: controller.search,
                  onNotificationsTap: () => context.push(AppRoutes.notifications),
                  onChatTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lista de mensajes (próximamente)')),
                  ),
                ),
                if (!isSearching)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        VaultSpacing.md,
                        VaultSpacing.md,
                        VaultSpacing.md,
                        VaultSpacing.xs,
                      ),
                      child: PromoCarousel(slides: state.slides),
                    ),
                  ),
                if (isSearching && state.items.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(VaultSpacing.xl),
                        child: Text(
                          "No se encontraron productos para \"${state.searchQuery}\"",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: VaultColors.textSecondary),
                        ),
                      ),
                    ),
                  )
                else
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
                          return GestureDetector(
                            onTap: () => context.push(
                              AppRoutes.productDetail,
                              extra: item,
                            ),
                            child: MarketplaceCard(
                              item: item,
                              onCartTap: () => _addToCart(context, ref, item),
                            ),
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







