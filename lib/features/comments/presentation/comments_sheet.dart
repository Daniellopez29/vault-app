import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/dimens.dart';
import '../../../core/theme.dart';
import '../domain/entities.dart';
import 'providers.dart';
import 'widgets.dart';

/// Abre el bottom sheet de comentarios para un post o artículo.
/// [target] es el mismo que se usa en [commentsControllerProvider].
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

class CommentsSheet extends ConsumerWidget {
  final CommentsTarget target;

  const CommentsSheet({super.key, required this.target});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(commentsControllerProvider(target));

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
                target: target,
                state: state,
                scrollController: scrollController,
              ),
            ),
            CommentInputBar(
              onSend: (text) => ref
                  .read(commentsControllerProvider(target).notifier)
                  .addComment(text),
            ),
          ],
        );
      },
    );
  }
}

class _CommentsBody extends ConsumerWidget {
  final CommentsTarget target;
  final CommentsState state;
  final ScrollController scrollController;

  const _CommentsBody({
    required this.target,
    required this.state,
    required this.scrollController,
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
          separatorBuilder: (_, _) =>
              const Divider(height: 1, color: VaultColors.divider),
          itemBuilder: (context, index) {
            final comment = state.comments[index];
            return CommentTile(
              comment: comment,
              onLike: () => ref
                  .read(commentsControllerProvider(target).notifier)
                  .toggleLike(comment.id),
            );
          },
        );
    }
  }
}
