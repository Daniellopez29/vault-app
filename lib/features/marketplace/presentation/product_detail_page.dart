import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/dimens.dart';
import '../../../core/router.dart';
import '../../../core/theme.dart';
import '../../auth/presentation/providers.dart';
import '../../cart/domain/entities.dart';
import '../../cart/presentation/providers.dart';
import '../../chat/presentation/chat_page.dart';
import '../../comments/domain/entities.dart';
import '../../comments/presentation/comments_sheet.dart';
import '../../maintenance/presentation/maintenance_list.dart';
import '../../maintenance/presentation/providers.dart';
import '../../reviews/presentation/reviews_tab.dart';
import '../domain/entities.dart';

/// Detalle de un producto del marketplace.
///
/// Estructura: galería de imágenes, precio, datos del artículo y una barra
/// inferior fija con las acciones de compra, siempre a mano sin importar
/// cuánto scroll haga el usuario.
class ProductDetailPage extends ConsumerWidget {
  final MarketplaceItemEntity item;

  const ProductDetailPage({super.key, required this.item});

  /// Imágenes del producto. Hoy la entidad expone una sola; se modela como
  /// lista para que la galería funcione igual cuando el backend envíe varias.
  List<String> get _images => [item.imageUrl];

  void _addToCart(BuildContext context, WidgetRef ref) {
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
      SnackBar(content: Text('${item.title} anadido al carrito')),
    );
  }

  void _buyNow(BuildContext context, WidgetRef ref) {
    _addToCart(context, ref);
    context.push(AppRoutes.cart);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(authControllerProvider).user?.id;
    final isOwnItem = currentUserId != null && currentUserId == item.sellerId;

    return Scaffold(
      backgroundColor: VaultColors.background,
      appBar: AppBar(
        backgroundColor: VaultColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: VaultColors.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            tooltip: 'Ver carrito',
            onPressed: () => context.push(AppRoutes.cart),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ProductGallery(images: _images, isVerified: item.isVerified),
          _PriceBand(price: item.price),
          Padding(
            padding: const EdgeInsets.all(VaultSpacing.md),
            child: _ProductInfo(item: item),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              VaultSpacing.md,
              0,
              VaultSpacing.md,
              VaultSpacing.lg,
            ),
            child: _OpinionsSection(productId: item.id),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              VaultSpacing.md,
              0,
              VaultSpacing.md,
              VaultSpacing.lg,
            ),
            child: _MaintenanceSection(assetId: item.id),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              VaultSpacing.md,
              0,
              VaultSpacing.md,
              VaultSpacing.lg,
            ),
            child: _SellerReviewsSection(sellerId: item.sellerId),
          ),
        ],
      ),
      bottomNavigationBar: _BuyBar(
        isOwnItem: isOwnItem,
        onChatTap: isOwnItem
            ? null
            : () => context.push(
                  AppRoutes.chat,
                  extra: ChatPageArgs(
                    recipientId: item.sellerId,
                    recipientName: item.sellerName,
                  ),
                ),
        onCartTap: () => _addToCart(context, ref),
        onBuyTap: () => _buyNow(context, ref),
      ),
    );
  }
}

/// Galería deslizable de imágenes del producto, con contador e indicadores.
class ProductGallery extends StatefulWidget {
  final List<String> images;
  final bool isVerified;

  const ProductGallery({
    super.key,
    required this.images,
    this.isVerified = false,
  });

  @override
  State<ProductGallery> createState() => _ProductGalleryState();
}

class _ProductGalleryState extends State<ProductGallery> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.images.length;

    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: PageView.builder(
            controller: _controller,
            itemCount: total,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) => _GalleryImage(url: widget.images[i]),
          ),
        ),
        if (widget.isVerified)
          Positioned(
            top: VaultSpacing.md,
            right: VaultSpacing.md,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: VaultSpacing.sm,
                vertical: VaultSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: VaultColors.accent,
                borderRadius: BorderRadius.circular(VaultRadius.sm),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_user,
                      color: Colors.white, size: VaultIconSize.sm),
                  SizedBox(width: VaultSpacing.xs),
                  Text(
                    'Verificado',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        // Contador de posición, como referencia de cuántas fotos hay.
        Positioned(
          bottom: VaultSpacing.md,
          right: VaultSpacing.md,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: VaultSpacing.sm,
              vertical: VaultSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(VaultRadius.sm),
            ),
            child: Text(
              '${_index + 1}/$total',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
        // Indicadores: solo tienen sentido con más de una imagen.
        if (total > 1)
          Positioned(
            bottom: VaultSpacing.md,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(total, (i) {
                final active = i == _index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: active ? Colors.white : Colors.white54,
                    borderRadius: BorderRadius.circular(VaultRadius.sm),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}

class _GalleryImage extends StatelessWidget {
  final String url;

  const _GalleryImage({required this.url});

  @override
  Widget build(BuildContext context) {
    final isPlaceholder = url.isEmpty || url.startsWith('assets/');

    if (isPlaceholder) {
      return Container(
        color: VaultColors.surface,
        alignment: Alignment.center,
        child: const Icon(
          Icons.image_outlined,
          size: VaultIconSize.xl,
          color: VaultColors.textSecondary,
        ),
      );
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) => Container(
        color: VaultColors.surface,
        alignment: Alignment.center,
        child: const Icon(
          Icons.broken_image_outlined,
          size: VaultIconSize.xl,
          color: VaultColors.textSecondary,
        ),
      ),
    );
  }
}

/// Franja con el precio, lo primero que se lee al bajar de la galería.
class _PriceBand extends StatelessWidget {
  final double price;

  const _PriceBand({required this.price});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      color: VaultColors.primary,
      padding: const EdgeInsets.symmetric(
        horizontal: VaultSpacing.md,
        vertical: VaultSpacing.md,
      ),
      child: Text(
        '\$${price.toStringAsFixed(0)}',
        style: tt.headlineMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Marca, título, calificación y especificaciones del producto.
class _ProductInfo extends StatelessWidget {
  final MarketplaceItemEntity item;

  const _ProductInfo({required this.item});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.brand, style: tt.titleMedium),
        const SizedBox(height: VaultSpacing.xs),
        Text(item.title, style: tt.titleLarge),
        const SizedBox(height: VaultSpacing.sm),
        Row(
          children: [
            const Icon(Icons.star,
                size: VaultIconSize.sm, color: VaultColors.accent),
            const SizedBox(width: VaultSpacing.xs),
            Text(
              item.rating > 0 ? item.rating.toStringAsFixed(1) : 'Sin calificar',
              style: tt.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: VaultSpacing.lg),
        Text('Detalles', style: tt.titleMedium),
        const SizedBox(height: VaultSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: VaultColors.surface,
            borderRadius: VaultRadius.cardBorder,
            border: Border.all(color: VaultColors.divider),
          ),
          child: Column(
            children: [
              _SpecRow(label: 'Origen', value: item.origin),
              const Divider(height: 1, color: VaultColors.divider),
              _SpecRow(label: 'Talla', value: item.size),
              const Divider(height: 1, color: VaultColors.divider),
              _SpecRow(
                label: 'Autenticidad',
                value: item.isVerified ? 'Verificado' : 'Sin verificar',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SpecRow extends StatelessWidget {
  final String label;
  final String value;

  const _SpecRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: VaultSpacing.md,
        vertical: VaultSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: tt.bodyMedium?.copyWith(color: VaultColors.textSecondary),
          ),
          Flexible(
            child: Text(
              value,
              style: tt.bodyMedium,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Barra inferior fija con las acciones de compra. [onChatTap] es `null`
/// cuando el producto es propio -- no tiene sentido contactarte a ti mismo.
class _BuyBar extends StatelessWidget {
  final bool isOwnItem;
  final VoidCallback? onChatTap;
  final VoidCallback onCartTap;
  final VoidCallback onBuyTap;

  const _BuyBar({
    required this.isOwnItem,
    required this.onChatTap,
    required this.onCartTap,
    required this.onBuyTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    // Es tu propio producto: no tiene sentido comprarlo ni agregarlo al
    // carrito (el backend lo rechaza igual, pero ocultarlo evita el viaje
    // redondo de agregar al carrito para enterarte hasta pagar).
    if (isOwnItem) {
      return Container(
        decoration: const BoxDecoration(
          color: VaultColors.surface,
          border: Border(top: BorderSide(color: VaultColors.divider)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(VaultSpacing.md),
            child: Text(
              'Este es tu producto en venta',
              style: tt.bodyMedium?.copyWith(color: VaultColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        color: VaultColors.surface,
        border: Border(top: BorderSide(color: VaultColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(VaultSpacing.md),
          child: Row(
            children: [
              if (onChatTap != null) ...[
                _BarAction(
                  icon: Icons.chat_bubble_outline,
                  label: 'Chat',
                  onTap: onChatTap!,
                ),
                const SizedBox(width: VaultSpacing.sm),
              ],
              OutlinedButton.icon(
                onPressed: onCartTap,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 52),
                  foregroundColor: VaultColors.primary,
                  side: const BorderSide(color: VaultColors.primary),
                  padding: const EdgeInsets.symmetric(
                    horizontal: VaultSpacing.lg,
                    vertical: VaultSpacing.md,
                  ),
                ),
                icon: const Icon(Icons.add_shopping_cart, size: VaultIconSize.sm),
                label: const Text('Carrito'),
              ),
              const SizedBox(width: VaultSpacing.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: onBuyTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VaultColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: VaultSpacing.md,
                    ),
                  ),
                  child: const Text('Comprar ahora'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




/// Acción compacta de la barra inferior (ícono + etiqueta debajo),
/// para las opciones secundarias como el chat con el vendedor.
class _BarAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BarAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(VaultRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: VaultSpacing.sm,
          vertical: VaultSpacing.xs,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: VaultIconSize.md, color: VaultColors.primary),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: VaultColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/// Acceso a las opiniones del producto. Reutiliza la feature de comentarios,
/// que trabaja sobre un targetId generico: aqui ese objetivo es el producto.
class _OpinionsSection extends StatelessWidget {
  final String productId;

  const _OpinionsSection({required this.productId});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Opiniones', style: tt.titleMedium),
        const SizedBox(height: VaultSpacing.sm),
        InkWell(
          onTap: () => showCommentsSheet(
            context,
            target: CommentsTarget(id: productId, type: CommentTargetType.asset),
          ),
          borderRadius: BorderRadius.circular(VaultRadius.card),
          child: Container(
            padding: const EdgeInsets.all(VaultSpacing.md),
            decoration: BoxDecoration(
              color: VaultColors.surface,
              borderRadius: VaultRadius.cardBorder,
              border: Border.all(color: VaultColors.divider),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.chat_bubble_outline,
                  color: VaultColors.primary,
                  size: VaultIconSize.md,
                ),
                const SizedBox(width: VaultSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ver opiniones', style: tt.titleSmall),
                      Text(
                        'Lee lo que opinan otros o deja la tuya',
                        style: tt.labelSmall?.copyWith(
                          color: VaultColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: VaultColors.textSecondary,
                  size: VaultIconSize.md,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Historial de mantenimiento del activo, de solo lectura -- el comprador
/// no puede agregar entradas, solo el dueño (ver [AssetDetailPage]).
class _MaintenanceSection extends ConsumerWidget {
  final String assetId;

  const _MaintenanceSection({required this.assetId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final state = ref.watch(maintenanceControllerProvider(assetId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Historial de mantenimiento', style: tt.titleMedium),
        const SizedBox(height: VaultSpacing.sm),
        MaintenanceList(state: state),
      ],
    );
  }
}

/// Reseñas del vendedor, de solo lectura -- publicarlas solo se puede desde
/// "Mis pedidos" tras una compra confirmada (ver [WriteReviewDialog]), nunca
/// desde el detalle del producto.
class _SellerReviewsSection extends StatelessWidget {
  final String sellerId;

  const _SellerReviewsSection({required this.sellerId});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Reseñas del vendedor', style: tt.titleMedium),
        const SizedBox(height: VaultSpacing.sm),
        ReviewsTab(providerId: sellerId, shrinkWrap: true),
      ],
    );
  }
}
