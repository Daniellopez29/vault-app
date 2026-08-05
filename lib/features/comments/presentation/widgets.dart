import 'package:flutter/material.dart';
import '../../../core/dimens.dart';
import '../../../core/theme.dart';
import '../domain/entities.dart';

/// Una fila de comentario con like, responder y swipe-to-delete.
class CommentTile extends StatelessWidget {
  final CommentEntity comment;
  final VoidCallback onLike;
  final VoidCallback? onDelete;
  final VoidCallback? onReply;

  const CommentTile({
    super.key,
    required this.comment,
    required this.onLike,
    this.onDelete,
    this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final isReply = comment.parentId != null;

    final tile = Padding(
      padding: EdgeInsets.only(
        top: VaultSpacing.sm,
        bottom: VaultSpacing.sm,
        left: isReply ? VaultSpacing.xl : 0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: isReply ? 14 : 18,
            backgroundColor: VaultColors.primary.withValues(alpha: 0.1),
            child: Text(
              comment.authorName.isNotEmpty
                  ? comment.authorName[0].toUpperCase()
                  : '?',
              style: tt.titleMedium?.copyWith(
                color: VaultColors.primary,
                fontSize: isReply ? 12 : 14,
              ),
            ),
          ),
          const SizedBox(width: VaultSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(comment.authorName, style: tt.titleMedium),
                    const SizedBox(width: VaultSpacing.sm),
                    Text(comment.timeAgo, style: tt.labelSmall),
                  ],
                ),
                const SizedBox(height: VaultSpacing.xs),
                Text(comment.text, style: tt.bodyLarge),
                const SizedBox(height: VaultSpacing.xs),
                Row(
                  children: [
                    GestureDetector(
                      onTap: onLike,
                      child: Row(
                        children: [
                          Icon(
                            comment.isLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 16,
                            color: comment.isLiked
                                ? VaultColors.error
                                : VaultColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${comment.likesCount}',
                            style: tt.labelSmall?.copyWith(
                              color: comment.isLiked
                                  ? VaultColors.error
                                  : VaultColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onReply != null) ...[
                      const SizedBox(width: VaultSpacing.lg),
                      GestureDetector(
                        onTap: onReply,
                        child: Row(
                          children: [
                            Icon(
                              Icons.reply,
                              size: 16,
                              color: VaultColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Responder',
                              style: tt.labelSmall?.copyWith(
                                color: VaultColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onDelete == null) return tile;

    return Dismissible(
      key: ValueKey(comment.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: VaultSpacing.lg),
        decoration: BoxDecoration(
          color: VaultColors.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(VaultRadius.sm),
        ),
        child: Icon(Icons.delete_outline, color: VaultColors.error),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Eliminar comentario'),
                content: const Text(
                  '¿Estás seguro de que quieres eliminar este comentario?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(
                      'Eliminar',
                      style: TextStyle(color: VaultColors.error),
                    ),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) => onDelete!(),
      child: tile,
    );
  }
}

/// Barra inferior para escribir un comentario nuevo.
class CommentInputBar extends StatefulWidget {
  final ValueChanged<String> onSend;
  final String? hintText;

  const CommentInputBar({super.key, required this.onSend, this.hintText});

  @override
  State<CommentInputBar> createState() => _CommentInputBarState();
}

class _CommentInputBarState extends State<CommentInputBar> {
  final _controller = TextEditingController();
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final can = _controller.text.trim().isNotEmpty;
      if (can != _canSend) setState(() => _canSend = can);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: VaultSpacing.md,
        vertical: VaultSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: VaultColors.surface,
        border: Border(top: BorderSide(color: VaultColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: TextStyle(color: VaultColors.primary),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                decoration: InputDecoration(
                  hintText: widget.hintText ?? 'Únete a la charla!',
                  filled: true,
                  fillColor: VaultColors.background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: VaultSpacing.md,
                    vertical: VaultSpacing.sm,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: VaultRadius.buttonBorder,
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: VaultSpacing.sm),
            IconButton(
              onPressed: _canSend ? _send : null,
              icon: Icon(
                Icons.send,
                color: _canSend
                    ? VaultColors.primary
                    : VaultColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
