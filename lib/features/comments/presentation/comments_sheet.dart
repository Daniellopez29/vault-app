import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/dimens.dart';
import '../../../core/theme.dart';
import '../domain/entities.dart';
import 'providers.dart';
import 'widgets.dart';

Future<void> showCommentsSheet(BuildContext context, {required CommentsTarget target}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: VaultColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(VaultRadius.card)),
    ),
    builder: (_) => CommentsSheet(target: target),
  );
}

class CommentsSheet extends ConsumerStatefulWidget {
  final CommentsTarget target;

  const CommentsSheet({super.key, required this.target});

  @override
  ConsumerState<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends ConsumerState<CommentsSheet> {
  CommentEntity? _replyingTo;

  void _setReply(CommentEntity comment) {
    setState(() => _replyingTo = comment);
  }

  void _clearReply() {
    setState(() => _replyingTo = null);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(commentsControllerProvider(widget.target));

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            const SizedBox(height: VaultSpacing.sm),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: VaultColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: VaultSpacing.md),
              child: Text(
                state.count == 0 ? 'Comentarios' : 'Comentarios (${state.count})',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(height: 1, color: VaultColors.divider),
            Expanded(
              child: _CommentsBody(
                target: widget.target,
                state: state,
                scrollController: scrollController,
                onReply: _setReply,
              ),
            ),
            if (_replyingTo != null)
              _ReplyBanner(
                authorName: _replyingTo!.authorName,
                onCancel: _clearReply,
              ),
            CommentInputBar(
              hintText: _replyingTo != null
                  ? 'Responder a ${_replyingTo!.authorName}...'
                  : null,
              onSend: (text) {
                ref
                    .read(commentsControllerProvider(widget.target).notifier)
                    .addComment(text, parentId: _replyingTo?.id);
                _clearReply();
              },
            ),
          ],
        );
      },
    );
  }
}

class _ReplyBanner extends StatelessWidget {
  final String authorName;
  final VoidCallback onCancel;

  const _ReplyBanner({required this.authorName, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: VaultSpacing.lg,
        vertical: VaultSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: VaultColors.primary.withValues(alpha: 0.06),
        border: Border(top: BorderSide(color: VaultColors.divider)),
      ),
      child: Row(
        children: [
          const Icon(Icons.reply, size: VaultIconSize.sm, color: VaultColors.primary),
          const SizedBox(width: VaultSpacing.sm),
          Expanded(
            child: Text(
              'Respondiendo a $authorName',
              style: const TextStyle(
                fontSize: 13,
                color: VaultColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: onCancel,
            child: const Icon(Icons.close, size: VaultIconSize.sm, color: VaultColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _CommentsBody extends ConsumerWidget {
  final CommentsTarget target;
  final CommentsState state;
  final ScrollController scrollController;
  final ValueChanged<CommentEntity> onReply;

  const _CommentsBody({
    required this.target,
    required this.state,
    required this.scrollController,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (state.status) {
      case CommentsStatus.initial:
      case CommentsStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case CommentsStatus.error:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(state.errorMessage ?? 'Error al cargar los comentarios'),
              const SizedBox(height: VaultSpacing.md),
              TextButton(
                onPressed: () => ref
                    .read(commentsControllerProvider(target).notifier)
                    .loadComments(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        );
      case CommentsStatus.loaded:
        if (state.comments.isEmpty) {
          return Center(
            child: Text(
              'Sé el primero en comentar',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }
        return ListView.separated(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(horizontal: VaultSpacing.lg),
          itemCount: state.comments.length,
          separatorBuilder: (_, __) =>
              const Divider(height: 1, color: VaultColors.divider),
          itemBuilder: (context, index) {
            final comment = state.comments[index];
            return CommentTile(
              comment: comment,
              onLike: () => ref
                  .read(commentsControllerProvider(target).notifier)
                  .toggleLike(comment.id),
              onDelete: () => ref
                  .read(commentsControllerProvider(target).notifier)
                  .deleteComment(comment.id),
              onReply: () => onReply(comment),
            );
          },
        );
    }
  }
}