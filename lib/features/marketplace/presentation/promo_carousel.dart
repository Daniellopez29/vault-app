import 'package:flutter/material.dart';
import '../../../core/dimens.dart';
import '../../../core/theme.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router.dart';
import '../../subscription/domain/entities.dart';
import '../domain/entities.dart';
import 'item_image.dart';
/// Carrusel de banners promocionales con indicadores de pÃ¡gina.
class PromoCarousel extends StatefulWidget {
  final List<CarouselSlide> slides;

  const PromoCarousel({super.key, required this.slides});

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
    if (widget.slides.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 120,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.slides.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: VaultSpacing.xs),
              child: _slideCard(context, widget.slides[i]),
            ),
          ),
        ),
        const SizedBox(height: VaultSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.slides.length, (i) {
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

  /// Elige la card según el tipo de slide. Sealed class => el switch cubre
  /// todos los casos y el compilador avisa si se agrega uno nuevo.
  Widget _slideCard(BuildContext context, CarouselSlide slide) {
    return switch (slide) {
      PromoSlide(:final banner) => _PromoCard(banner: banner),
      SubscriptionSlide(:final type) => _SubscriptionCard(
        type: type,
        onTap: () => context.push(AppRoutes.subscription, extra: type),
      ),
    };
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
              child: ItemImage(imageUrl: banner.imageUrl),
            ),
          ),
        ],
      ),
    );
  }
}





/// Card de suscripción dentro del carrusel. Mismo tamaño que _PromoCard
/// (alto 120) para que el carrusel no salte. Fondo accent porque es una
/// señal de compra. El texto se resuelve desde SubscriptionCopy (dominio),
/// no se hardcodea aquí.
class _SubscriptionCard extends StatelessWidget {
  final SubscriptionType type;
  final VoidCallback onTap;

  const _SubscriptionCard({required this.type, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Material(
      color: VaultColors.accent,
      borderRadius: VaultRadius.cardBorder,
      child: InkWell(
        borderRadius: VaultRadius.cardBorder,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(VaultSpacing.md),
          child: Row(
            children: [
              const Icon(Icons.workspace_premium_outlined,
                  color: Colors.white, size: VaultIconSize.xl),
              const SizedBox(width: VaultSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      SubscriptionCopy.titleFor(type),
                      style: tt.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: VaultSpacing.xs),
                    Text(
                      SubscriptionCopy.subtitleFor(type),
                      style: tt.bodySmall?.copyWith(color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

