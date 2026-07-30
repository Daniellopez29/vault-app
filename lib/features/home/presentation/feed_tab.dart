import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/dimens.dart';
import '../../../core/router.dart';
import '../../../core/theme.dart';
import '../../../core/widgets/search_header.dart';
import '../../ads/domain/entities.dart';
import '../../ads/presentation/ad_impression_tracker.dart';
import '../../ads/presentation/ad_interleave.dart';
import '../../ads/presentation/providers.dart';
import '../../chat/presentation/providers.dart' show conversationsControllerProvider;
import '../../comments/domain/entities.dart';
import '../../comments/presentation/comments_sheet.dart';
import '../../notifications/presentation/providers.dart' show notificationsControllerProvider;
import '../domain/entities.dart';
import '../../auth/presentation/providers.dart' show authControllerProvider;
import 'feed_skeleton.dart';
import 'providers.dart';

class FeedTab extends ConsumerWidget {
  const FeedTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(feedControllerProvider);
    final ads = ref.watch(activeAdsControllerProvider(AdSection.feed)).ads;
    final unreadNotifications =
        ref.watch(notificationsControllerProvider).notifications.where((n) => !n.read).length;
    final unreadChats = ref
        .watch(conversationsControllerProvider)
        .conversations
        .fold(0, (sum, c) => sum + c.unreadCount);

    switch (state.status) {
      case FeedStatus.initial:
      case FeedStatus.loading:
        return const FeedSkeleton();
      case FeedStatus.error:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(state.errorMessage ?? 'Error al cargar el feed'),
              const SizedBox(height: VaultSpacing.md),
              TextButton(
                onPressed: () => ref.read(feedControllerProvider.notifier).loadFeed(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        );
      case FeedStatus.loaded:
        final controller = ref.read(feedControllerProvider.notifier);
        final currentUserId = ref.watch(authControllerProvider).user?.id ?? '';
        final posts = state.visiblePosts;
        // Igual que en el Shop: sin anuncios mientras se busca, para no
        // interrumpir resultados que el usuario está filtrando a propósito.
        final feedCells = state.isSearching ? posts : interleaveAds(posts, ads);

        return RefreshIndicator(
          onRefresh: () => ref.read(feedControllerProvider.notifier).loadFeed(),
          child: CustomScrollView(
            slivers: [
              VaultSearchHeader(
                query: state.searchQuery,
                hintText: "Buscar publicaciones",
                onQueryChanged: controller.search,
                onNotificationsTap: () => context.push(AppRoutes.notifications),
                onChatTap: () => context.push(AppRoutes.conversations),
                unreadNotificationsCount: unreadNotifications,
                unreadChatCount: unreadChats,
              ),
              if (posts.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(VaultSpacing.xl),
                      child: Text(
                        state.isSearching
                            ? "No se encontraron publicaciones"
                            : "Aún no hay publicaciones",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: VaultColors.textSecondary),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(VaultSpacing.md),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final cell = feedCells[index];
                        Widget child;
                        if (cell is AdEntity) {
                          child = AdImpressionTracker(ad: cell, child: _AdFeedCard(ad: cell));
                        } else {
                          final post = cell as PostEntity;
                          child = PostCard(
                            post: post,
                            onLikeTap: () => controller.toggleLike(post.id),
                            onSaveTap: () => controller.toggleSave(post.id),
                            onDeleteTap: post.authorId == currentUserId
                                ? () => controller.deletePost(post.id)
                                : null,
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.only(bottom: VaultSpacing.lg),
                          child: child,
                        );
                      },
                      childCount: feedCells.length,
                    ),
                  ),
                ),
            ],
          ),
        );
    }
  }
}

class PostCard extends StatefulWidget {
  final PostEntity post;
  final VoidCallback onLikeTap;
  final VoidCallback onSaveTap;
  final VoidCallback? onDeleteTap;

  const PostCard({
    super.key,
    required this.post,
    required this.onLikeTap,
    required this.onSaveTap,
    this.onDeleteTap,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final post = widget.post;

    return Container(
      decoration: BoxDecoration(
        color: VaultColors.surface,
        borderRadius: VaultRadius.cardBorder,
        boxShadow: VaultShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Si la publicación se subió sin foto, no se reserva el espacio
          // de la imagen -- antes quedaba un bloque gris vacío arriba del
          // texto aunque no hubiera nada que mostrar ahí.
          if (post.imageUrl.isNotEmpty && !post.imageUrl.startsWith('assets/'))
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(VaultRadius.card),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 11,
                child: Image.network(post.imageUrl, fit: BoxFit.cover),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: VaultSpacing.lg,
              vertical: VaultSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(post.title, style: tt.titleLarge),
                          Text(post.timeAgo, style: tt.bodyMedium),
                        ],
                      ),
                    ),
                    Text(post.authorName, style: tt.titleMedium),
                  ],
                ),
                const SizedBox(height: VaultSpacing.sm),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 200),
                  crossFadeState: _expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: Text(
                    post.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: tt.bodyLarge,
                  ),
                  secondChild: Text(post.description, style: tt.bodyLarge),
                ),
                GestureDetector(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: VaultIconSize.sm,
                    color: VaultColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              right: VaultSpacing.lg,
              bottom: VaultSpacing.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _ActionStat(
                  icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                  count: post.likesCount,
                  color: post.isLiked
                      ? VaultColors.error
                      : VaultColors.textPrimary,
                  onTap: widget.onLikeTap,
                ),
                const SizedBox(width: VaultSpacing.lg),
                _ActionStat(
                  icon: Icons.chat_bubble_outline,
                  count: post.commentsCount,
                  color: VaultColors.textPrimary,
                  onTap: () => showCommentsSheet(
                    context,
                    target: CommentsTarget(id: post.id, type: CommentTargetType.post),
                  ),
                ),
                const SizedBox(width: VaultSpacing.lg),
                // _ActionStat en vez de IconButton: antes el ícono de
                // guardar quedaba centrado en un bloque más chico (solo
                // ícono) mientras que like/comentarios usan una columna más
                // alta (ícono + número debajo), así que el de guardar se
                // veía más abajo que los otros dos en la misma fila.
                _ActionStat(
                  icon: post.isSaved ? Icons.bookmark : Icons.bookmark_border,
                  count: null,
                  color: VaultColors.textPrimary,
                  onTap: widget.onSaveTap,
                ),
                if (widget.onDeleteTap != null)
                  IconButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Eliminar publicación'),
                          content: const Text('Esta acción no se puede deshacer.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Eliminar',
                                  style: TextStyle(color: VaultColors.error)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) widget.onDeleteTap!();
                    },
                    icon: const Icon(Icons.delete_outline,
                        color: VaultColors.textSecondary, size: VaultIconSize.md),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionStat extends StatelessWidget {
  final IconData icon;
  final int? count;
  final Color color;
  final VoidCallback onTap;

  const _ActionStat({
    required this.icon,
    required this.count,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: VaultIconSize.md, color: color),
          // Texto vacío (no null) cuando no hay conteo -- conserva el
          // mismo alto que un número real, para que el ícono quede a la
          // misma altura que los que sí cuentan algo.
          Text(count != null ? '$count' : '', style: tt.labelSmall?.copyWith(color: color)),
        ],
      ),
    );
  }
}

/// Card de anuncio dentro del feed -- mismo lenguaje visual que [PostCard]
/// (misma silueta: imagen 16/11 arriba, contenido debajo) para que no
/// desentone entre publicaciones reales, pero marcado como "Patrocinado".
class _AdFeedCard extends StatelessWidget {
  final AdEntity ad;

  const _AdFeedCard({required this.ad});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: VaultColors.surface,
        borderRadius: VaultRadius.cardBorder,
        boxShadow: VaultShadows.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 11,
            child: ad.imageUrl.isEmpty
                ? Container(
                    color: VaultColors.background,
                    child: Icon(Icons.campaign_outlined,
                        size: VaultIconSize.xl, color: VaultColors.textSecondary),
                  )
                : Image.network(ad.imageUrl, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: VaultSpacing.lg,
              vertical: VaultSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Patrocinado',
                    style: tt.labelSmall?.copyWith(color: VaultColors.textSecondary)),
                const SizedBox(height: VaultSpacing.xs),
                Text(ad.title, style: tt.titleLarge),
                if (ad.description.isNotEmpty) ...[
                  const SizedBox(height: VaultSpacing.xs),
                  Text(ad.description, style: tt.bodyLarge, maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
