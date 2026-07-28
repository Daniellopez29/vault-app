import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../home/domain/entities.dart';

class FavoriteCard extends StatelessWidget {
  final PostEntity post;
  final VoidCallback onRemove;

  const FavoriteCard({
    super.key,
    required this.post,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: VaultColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              // Antes solo revisaba el prefijo 'assets/', así que un post
              // sin foto (imageUrl vacío) caía al Image.network('') de
              // abajo y nunca mostraba nada -- mismo chequeo que ya usa
              // PostCard en el feed.
              child: post.imageUrl.isEmpty || post.imageUrl.startsWith('assets/')
                  ? Container(
                color: VaultColors.background,
                child: Icon(
                  Icons.image_outlined,
                  size: 48,
                  color: VaultColors.textSecondary,
                ),
              )
                  : Image.network(post.imageUrl, fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // post.title del backend siempre viene vacío (ver
                      // PostModel.fromJson) -- el texto real de la
                      // publicación es post.description, lo que muestra
                      // PostCard en el feed. Antes esta tarjeta se quedaba
                      // con un hueco vacío donde debía ir el contenido.
                      Text(
                        post.description,
                        style: tt.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(post.authorName, style: tt.titleSmall),
                      const SizedBox(height: 4),
                      Text(post.timeAgo, style: tt.bodyMedium),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: Icon(
                    Icons.bookmark,
                    color: VaultColors.accent,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyFavoritesView extends StatelessWidget {
  const EmptyFavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bookmark_border, size: 64, color: VaultColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            'Aún no tienes publicaciones guardadas',
            textAlign: TextAlign.center,
            style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Guarda publicaciones desde el feed para verlas aquí',
            textAlign: TextAlign.center,
            style: tt.bodyMedium,
          ),
        ],
      ),
    );
  }
}