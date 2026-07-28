import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/dimens.dart';
import '../../../core/router.dart';
import '../../../core/theme.dart';
import '../../ads/domain/entities.dart';
import '../../ads/presentation/ad_impression_tracker.dart';
import '../../ads/presentation/ad_interleave.dart';
import '../../ads/presentation/providers.dart';
import '../../cart/domain/entities.dart';
import '../../cart/presentation/providers.dart';
import '../../chat/presentation/providers.dart' show conversationsControllerProvider;
import '../../notifications/presentation/providers.dart' show notificationsControllerProvider;
import '../../subscription/presentation/providers.dart';
import '../domain/entities.dart';
import 'providers.dart';
import '../../../core/widgets/search_header.dart';
import 'shop_skeleton.dart';
import 'marketplace_card.dart';
import 'promo_carousel.dart';
import 'item_image.dart';

class ShopTab extends ConsumerWidget {
  const ShopTab({super.key});

  void _addToCart(BuildContext context, WidgetRef ref, MarketplaceItemEntity item) {
    ref.read(cartControllerProvider.notifier).addItem(
      CartItemEntity(
        id: item.id,
        sellerId: item.sellerId,
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
    final ads = ref.watch(activeAdsControllerProvider(AdSection.marketplace)).ads;
    final hasActiveSubscription =
        ref.watch(subscriptionStatusControllerProvider).subscription?.isActive ?? false;
    final unreadNotifications =
        ref.watch(notificationsControllerProvider).notifications.where((n) => !n.read).length;
    final unreadChats = ref
        .watch(conversationsControllerProvider)
        .conversations
        .fold(0, (sum, c) => sum + c.unreadCount);

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
        // Durante una búsqueda no se intercalan anuncios -- mismo criterio
        // que el carrusel, que tampoco se muestra mientras se busca.
        final gridCells =
            isSearching ? state.items : interleaveAds(state.items, ads);

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
                  onChatTap: () => context.push(AppRoutes.conversations),
                  unreadNotificationsCount: unreadNotifications,
                  unreadChatCount: unreadChats,
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
                      child: PromoCarousel(
                        slides: [
                          // Ya suscrito, no tiene caso seguir ofreciéndole
                          // el mismo plan que ya compró.
                          ...state.slides.where(
                            (s) => s is! SubscriptionSlide || !hasActiveSubscription,
                          ),
                          ...ads.map(AdSlide.new),
                        ],
                      ),
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
                          final cell = gridCells[index];
                          if (cell is AdEntity) {
                            return AdImpressionTracker(
                              ad: cell,
                              onTap: () {
                                // Si el anuncio apunta a un producto que ya
                                // está cargado en el catálogo, se navega a
                                // su detalle -- si no (p.ej. se vendió o ya
                                // no está en venta), el clic igual queda
                                // registrado, solo no hay a dónde ir.
                                final target = state.items
                                    .where((i) => i.id == cell.targetId)
                                    .firstOrNull;
                                if (target != null) {
                                  context.push(AppRoutes.productDetail, extra: target);
                                }
                              },
                              child: _AdGridCard(ad: cell),
                            );
                          }
                          final item = cell as MarketplaceItemEntity;
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
                        childCount: gridCells.length,
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

/// Card de anuncio dentro del grid de productos -- mismo tamaño que
/// [MarketplaceCard] (`mainAxisExtent: 255` en el `SliverGrid`) para no
/// romper el layout.
class _AdGridCard extends StatelessWidget {
  final AdEntity ad;

  const _AdGridCard({required this.ad});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: VaultColors.primary,
        borderRadius: VaultRadius.cardBorder,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: ItemImage(imageUrl: ad.imageUrl)),
          Padding(
            padding: const EdgeInsets.all(VaultSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Patrocinado',
                  style: tt.labelSmall?.copyWith(color: Colors.white70),
                ),
                Text(
                  ad.title,
                  style: tt.titleSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}







