import 'package:flutter/material.dart';
import '../../../core/dimens.dart';
import '../../../core/theme.dart';
import '../domain/entities.dart';

/// Una fila de comentario: avatar, autor, texto, fecha y like.
class CommentTile extends StatelessWidget {
  final CommentEntity comment;
  final VoidCallback onLike;

  const CommentTile({
    super.key,
    required this.comment,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: VaultSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: VaultColors.primary.withValues(alpha: 0.1),
            child: Text(
              comment.authorName.isNotEmpty
                  ? comment.authorName[0].toUpperCase()
                  : '?',
              style: tt.titleMedium?.copyWith(color: VaultColors.primary),
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
              ],
            ),
          ),
          const SizedBox(width: VaultSpacing.sm),
          Column(
            children: [
              InkWell(
                onTap: onLike,
                borderRadius: VaultRadius.buttonBorder,
                child: Padding(
                  padding: const EdgeInsets.all(VaultSpacing.xs),
                  child: Icon(
                    comment.isLiked ? Icons.favorite : Icons.favorite_border,
                    size: VaultIconSize.sm,
                    color: comment.isLiked
                        ? VaultColors.error
                        : VaultColors.textSecondary,
                  ),
                ),
              ),
              Text('${comment.likesCount}', style: tt.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}

/// Barra inferior para escribir un comentario nuevo.
class CommentInputBar extends StatefulWidget {
  final ValueChanged<String> onSend;

  const CommentInputBar({super.key, required this.onSend});

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
          horizontal: VaultSpacing.md, vertical: VaultSpacing.sm),
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
                style: const TextStyle(color: VaultColors.primary),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                decoration: InputDecoration(
                  hintText: 'Únete a la charla!',
                  filled: true,
                  fillColor: VaultColors.background,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: VaultSpacing.md, vertical: VaultSpacing.sm),
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