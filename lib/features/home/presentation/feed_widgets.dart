import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities.dart';
import 'providers.dart';

const _kDark = Color(0xFF2D2D3A);

class FeedTab extends ConsumerWidget {
  const FeedTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(feedControllerProvider);

    switch (state.status) {
      case FeedStatus.initial:
      case FeedStatus.loading:
        return const Center(child: CircularProgressIndicator(color: _kDark));
      case FeedStatus.error:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(state.errorMessage ?? 'Error al cargar el feed'),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => ref.read(feedControllerProvider.notifier).loadFeed(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        );
      case FeedStatus.loaded:
        if (state.posts.isEmpty) {
          return const Center(child: Text('Aún no hay publicaciones'));
        }
        return RefreshIndicator(
          onRefresh: () => ref.read(feedControllerProvider.notifier).loadFeed(),
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: state.posts.length,
            itemBuilder: (context, index) {
              final post = state.posts[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: PostCard(
                  post: post,
                  onLikeTap: () => ref.read(feedControllerProvider.notifier).toggleLike(post.id),
                  onSaveTap: () => ref.read(feedControllerProvider.notifier).toggleSave(post.id),
                ),
              );
            },
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
    final post = widget.post;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: AspectRatio(
              aspectRatio: 16 / 11,
              child: post.imageUrl.startsWith('assets/')
                  ? Container(
                color: Colors.grey.shade300,
                child: const Icon(Icons.image_outlined, size: 48, color: Colors.grey),
              )
                  : Image.network(post.imageUrl, fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
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
                          Text(post.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(post.timeAgo,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                    Text(post.authorName,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 8),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 200),
                  crossFadeState:
                  _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  firstChild: Text(
                    post.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                  ),
                  secondChild: Text(
                    post.description,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Icon(
                    _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _ActionStat(
                  icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                  count: post.likesCount,
                  color: post.isLiked ? Colors.red : _kDark,
                  onTap: widget.onLikeTap,
                ),
                const SizedBox(width: 16),
                _ActionStat(
                  icon: Icons.chat_bubble_outline,
                  count: post.commentsCount,
                  color: _kDark,
                  onTap: () {},
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: widget.onSaveTap,
                  icon: Icon(
                    post.isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: _kDark,
                    size: 22,
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
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          Text('$count', style: TextStyle(fontSize: 11, color: color)),
        ],
      ),
    );
  }
}