import 'package:flutter/material.dart';
import '../../../core/dimens.dart';
import '../../../core/theme.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router.dart';
import '../../subscription/domain/entities.dart';
import '../domain/entities.dart';

/// Muestra la imagen de red si es una URL real; si aÃºn es un asset mock
/// (los datos de prueba no estÃ¡n empaquetados), cae a un placeholder.
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

/// Tarjeta de un artÃ­culo del marketplace (grid de 2 columnas).
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
              child: _ItemImage(imageUrl: banner.imageUrl),
            ),
          ),
        ],
      ),
    );
  }
}

class ShopSearchHeader extends StatelessWidget {
  final String query;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onNotificationsTap;
  final VoidCallback onChatTap;

  const ShopSearchHeader({
    super.key,
    required this.query,
    required this.onQueryChanged,
    required this.onNotificationsTap,
    required this.onChatTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: VaultColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: VaultSpacing.md,
      toolbarHeight: 68,
      title: Row(
        children: [
          Expanded(child: _SearchField(query: query, onChanged: onQueryChanged)),
          const SizedBox(width: VaultSpacing.sm),
          _HeaderIconButton(
            icon: Icons.notifications_outlined,
            onTap: onNotificationsTap,
          ),
          _HeaderIconButton(
            icon: Icons.chat_bubble_outline,
            onTap: onChatTap,
          ),
        ],
      ),
    );
  }
}

/// Campo de bÃºsqueda controlado. Muestra una "X" para limpiar cuando hay texto.
class _SearchField extends StatefulWidget {
  final String query;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.query, required this.onChanged});

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);
  }

  @override
  void didUpdateWidget(covariant _SearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Mantiene el campo sincronizado si el estado se limpia desde fuera.
    if (widget.query != _controller.text) {
      _controller.text = widget.query;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      textInputAction: TextInputAction.search,
      style: const TextStyle(color: VaultColors.textPrimary),
      decoration: InputDecoration(
        hintText: 'Buscar productos',
        hintStyle: const TextStyle(color: VaultColors.textSecondary),
        prefixIcon: const Icon(
          Icons.search,
          color: VaultColors.textSecondary,
          size: VaultIconSize.md,
        ),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(
                  Icons.close,
                  color: VaultColors.textSecondary,
                  size: VaultIconSize.sm,
                ),
                onPressed: () {
                  _controller.clear();
                  widget.onChanged('');
                },
              ),
        filled: true,
        fillColor: VaultColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          vertical: VaultSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(VaultRadius.card),
          borderSide: const BorderSide(color: VaultColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(VaultRadius.card),
          borderSide: const BorderSide(color: VaultColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(VaultRadius.card),
          borderSide: const BorderSide(color: VaultColors.primary),
        ),
      ),
    );
  }
}

/// BotÃ³n de Ã­cono del header (notificaciones / chat), con estilo consistente.
class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        icon,
        color: VaultColors.textPrimary,
        size: VaultIconSize.lg,
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

