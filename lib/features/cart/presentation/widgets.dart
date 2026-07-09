import 'package:flutter/material.dart';
import '../../../core/dimens.dart';
import '../../../core/theme.dart';
import '../domain/entities.dart';

/// Imagen del ítem: red si es URL real, placeholder si aún es asset mock.
class CartItemImage extends StatelessWidget {
  final String imageUrl;
  final double size;

  const CartItemImage({super.key, required this.imageUrl, this.size = 64});

  @override
  Widget build(BuildContext context) {
    final isPlaceholder = imageUrl.isEmpty || imageUrl.startsWith('assets/');
    return ClipRRect(
      borderRadius: VaultRadius.cardBorder,
      child: SizedBox(
        width: size,
        height: size,
        child: isPlaceholder
            ? Container(
          color: VaultColors.background,
          alignment: Alignment.center,
          child: Icon(
            Icons.image_outlined,
            color: VaultColors.textSecondary,
            size: VaultIconSize.lg,
          ),
        )
            : Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            color: VaultColors.background,
            alignment: Alignment.center,
            child: Icon(
              Icons.broken_image_outlined,
              color: VaultColors.textSecondary,
              size: VaultIconSize.lg,
            ),
          ),
        ),
      ),
    );
  }
}

/// Fila de un artículo en el carrito: imagen, datos, precio y quitar.
class CartItemRow extends StatelessWidget {
  final CartItemEntity item;
  final VoidCallback onRemove;

  const CartItemRow({
    super.key,
    required this.item,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: VaultSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CartItemImage(imageUrl: item.imageUrl),
          const SizedBox(width: VaultSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: tt.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  item.brand,
                  style: tt.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: VaultSpacing.sm),
                Text(
                  '\$${item.lineTotal.toStringAsFixed(0)}',
                  style: tt.titleLarge,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: Icon(
              Icons.close,
              color: VaultColors.textSecondary,
              size: VaultIconSize.md,
            ),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

/// Fila del resumen de costos (Subtotal, Tarifa, Descuento, Total).
class SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasized;

  const SummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final labelStyle = emphasized ? tt.titleLarge : tt.bodyLarge;
    final valueStyle = emphasized
        ? tt.titleLarge
        : tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: VaultSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: labelStyle),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }
}