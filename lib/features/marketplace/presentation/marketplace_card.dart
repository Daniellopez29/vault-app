import 'package:flutter/material.dart';
import '../../../core/dimens.dart';
import '../../../core/theme.dart';
import '../domain/entities.dart';
import 'item_image.dart';

/// Tarjeta de un artículo del marketplace (grid de 2 columnas).
class MarketplaceCard extends StatelessWidget {
  final MarketplaceItemEntity item;
  final VoidCallback? onCartTap;

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
              Positioned.fill(child: ItemImage(imageUrl: item.imageUrl)),
              if (item.isVerified)
                Positioned(
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
                    Icon(
                      Icons.star,
                      size: VaultIconSize.sm,
                      color: VaultColors.accent,
                    ),
                    const SizedBox(width: VaultSpacing.xs),
                    Text(item.rating.toStringAsFixed(1), style: tt.titleMedium),
                  ],
                ),
                // onCartTap es null cuando el producto es tuyo -- no tiene
                // sentido dejarte agregarlo al carrito.
                if (onCartTap != null)
                  InkWell(
                    onTap: onCartTap,
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      size: VaultIconSize.md,
                      color: VaultColors.primary,
                    ),
                  )
                else
                  Text('Tuyo', style: tt.labelSmall),
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
                Text(
                  'Vendido por ${item.sellerName}',
                  style: tt.labelSmall?.copyWith(
                    color: VaultColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.servicesCount > 0 || item.restorationsCount > 0) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.build_outlined,
                        size: VaultIconSize.sm,
                        color: VaultColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        [
                          if (item.servicesCount > 0)
                            '${item.servicesCount} servicios',
                          if (item.restorationsCount > 0)
                            '${item.restorationsCount} restauraciones',
                        ].join(' · '),
                        style: tt.labelSmall?.copyWith(
                          color: VaultColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
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
