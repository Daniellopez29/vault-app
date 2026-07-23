import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/dimens.dart';
import '../../../core/router.dart';
import '../../../core/theme.dart';
import '../../../core/widgets/search_header.dart';
import '../../comments/domain/entities.dart';
import '../../comments/presentation/comments_sheet.dart';
import '../domain/entities.dart';
import 'feed_skeleton.dart';
import 'providers.dart';

class FeedTab extends ConsumerWidget {
  const FeedTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(feedControllerProvider);

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
        final posts = state.visiblePosts;

        return RefreshIndicator(
          onRefresh: () => ref.read(feedControllerProvider.notifier).loadFeed(),
          child: CustomScrollView(
            slivers: [
              VaultSearchHeader(
                query: state.searchQuery,
                hintText: "Buscar publicaciones",
                onQueryChanged: controller.search,
                onNotificationsTap: () => context.push(AppRoutes.notifications),
                onChatTap: () => context.push(AppRoutes.chat),
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
                        final post = posts[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: VaultSpacing.lg),
                          child: PostCard(
                            post: post,
                            onLikeTap: () => controller.toggleLike(post.id),
                            onSaveTap: () => controller.toggleSave(post.id),
                          ),
                        );
                      },
                      childCount: posts.length,
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

  const PostCard({
    super.key,
    required this.post,
    required this.onLikeTap,
    required this.onSaveTap,
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
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(VaultRadius.card),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 11,
              child: post.imageUrl.isEmpty || post.imageUrl.startsWith('assets/')
                  ? Container(
                color: VaultColors.background,
                child: Icon(
                  Icons.image_outlined,
                  size: VaultIconSize.xl,
                  color: VaultColors.textSecondary,
                ),
              )
                  : Image.network(post.imageUrl, fit: BoxFit.cover),
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
                IconButton(
                  onPressed: widget.onSaveTap,
                  icon: Icon(
                    post.isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: VaultColors.textPrimary,
                    size: VaultIconSize.md,
                  ),
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
  final int count;
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
          Text('$count', style: tt.labelSmall?.copyWith(color: color)),
        ],
      ),
    );
  }
}

