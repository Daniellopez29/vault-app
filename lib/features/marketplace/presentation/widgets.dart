import 'package:flutter/material.dart';
import '../../../core/dimens.dart';
import '../../../core/theme.dart';
import '../domain/entities.dart';

/// Muestra la imagen de red si es una URL real; si aún es un asset mock
/// (los datos de prueba no están empaquetados), cae a un placeholder.
class _ItemImage extends StatelessWidget {
  final String imageUrl;

  const _ItemImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final isPlaceholder = imageUrl.isEmpty || imageUrl.startsWith('assets/');

    if (isPlaceholder) {
      return Container(
        color: VaultColors.background,
        alignment: Alignment.center,
        child: Icon(
          Icons.image_outlined,
          size: VaultIconSize.xl,
          color: VaultColors.textSecondary,
        ),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: VaultColors.background,
        alignment: Alignment.center,
        child: Icon(
          Icons.broken_image_outlined,
          size: VaultIconSize.xl,
          color: VaultColors.textSecondary,
        ),
      ),
    );
  }
}

/// Tarjeta de un artículo del marketplace (grid de 2 columnas).
class MarketplaceCard extends StatelessWidget {
  final MarketplaceItemEntity item;
  final VoidCallback onCartTap;

  const MarketplaceCard({
    super.key,
    required this.item,
    required this.onCartTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: VaultColors.surface,
        borderRadius: VaultRadius.cardBorder,
        border: Border.all(color: VaultColors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              const SizedBox(height: 120, width: double.infinity),
              Positioned.fill(child: _ItemImage(imageUrl: item.imageUrl)),
              if (item.isVerified)
                const Positioned(
                  top: VaultSpacing.sm,
                  right: VaultSpacing.sm,
                  child: Icon(
                    Icons.verified_user,
                    color: VaultColors.accent,
                    size: VaultIconSize.md,
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              VaultSpacing.sm,
              VaultSpacing.sm,
              VaultSpacing.sm,
              VaultSpacing.xs,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star,
                        size: VaultIconSize.sm, color: VaultColors.accent),
                    const SizedBox(width: VaultSpacing.xs),
                    Text(item.rating.toStringAsFixed(1), style: tt.titleMedium),
                  ],
                ),
                InkWell(
                  onTap: onCartTap,
                  child: const Icon(
                    Icons.shopping_cart_outlined,
                    size: VaultIconSize.md,
                    color: VaultColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              VaultSpacing.sm,
              0,
              VaultSpacing.sm,
              VaultSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.brand,
                  style: tt.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  item.title,
                  style: tt.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: VaultSpacing.xs),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Origen: ${item.origin}',
                            style: tt.labelSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text('Talla: ${item.size}', style: tt.labelSmall),
                        ],
                      ),
                    ),
                    const SizedBox(width: VaultSpacing.xs),
                    Text(
                      '\$${item.price.toStringAsFixed(0)}',
                      style: tt.titleLarge?.copyWith(
                        color: VaultColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Carrusel de banners promocionales con indicadores de página.
class PromoCarousel extends StatefulWidget {
  final List<PromoBannerEntity> banners;

  const PromoCarousel({super.key, required this.banners});

  @override
  State<PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<PromoCarousel> {
  final PageController _controller = PageController(viewportFraction: 0.92);
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 120,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.banners.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: VaultSpacing.xs),
              child: _PromoCard(banner: widget.banners[i]),
            ),
          ),
        ),
        const SizedBox(height: VaultSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.banners.length, (i) {
            final active = i == _index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? VaultColors.primary : VaultColors.divider,
                borderRadius: BorderRadius.circular(VaultRadius.sm),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _PromoCard extends StatelessWidget {
  final PromoBannerEntity banner;

  const _PromoCard({required this.banner});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: VaultColors.primary,
        borderRadius: VaultRadius.cardBorder,
      ),
      padding: const EdgeInsets.all(VaultSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  banner.sellerName,
                  style: tt.labelSmall?.copyWith(
                    color: cs.onPrimary.withValues(alpha: 0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  banner.title,
                  style: tt.titleMedium?.copyWith(
                    color: cs.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: VaultSpacing.xs),
                Row(
                  children: [
                    Text(
                      '\$${banner.price.toStringAsFixed(0)}',
                      style: tt.bodyLarge?.copyWith(
                        color: cs.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: VaultSpacing.sm),
                    Text(
                      '\$${banner.oldPrice.toStringAsFixed(0)}',
                      style: tt.labelSmall?.copyWith(
                        color: cs.onPrimary.withValues(alpha: 0.5),
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: VaultSpacing.sm),
                SizedBox(
                  height: 26,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: VaultColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: VaultSpacing.lg),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(VaultRadius.sm),
                      ),
                    ),
                    child: const Text(
                      'Buy now',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: VaultSpacing.sm),
          SizedBox(
            width: 84,
            height: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(VaultRadius.button),
              child: _ItemImage(imageUrl: banner.imageUrl),
            ),
          ),
        ],
      ),
    );
  }
}