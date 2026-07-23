import 'package:flutter/material.dart';
import '../../../core/dimens.dart';
import '../../../core/theme.dart';

/// Muestra la imagen de red si es una URL real; si aún es un asset mock
/// (los datos de prueba no están empaquetados), cae a un placeholder.
///
/// Es publica porque la usan tanto la tarjeta del grid como el carrusel.
class ItemImage extends StatelessWidget {
  final String imageUrl;

  const ItemImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final isPlaceholder = imageUrl.isEmpty || imageUrl.startsWith('assets/');

    if (isPlaceholder) {
      return Container(
        color: VaultColors.background,
        alignment: Alignment.center,
        child: const Icon(
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
        child: const Icon(
          Icons.broken_image_outlined,
          size: VaultIconSize.xl,
          color: VaultColors.textSecondary,
        ),
      ),
    );
  }
}