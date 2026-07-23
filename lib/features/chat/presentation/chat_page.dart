import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/dimens.dart';
import '../../../core/theme.dart';
import '../../auth/presentation/providers.dart';
import '../domain/entities.dart';
import 'providers.dart';

/// Datos para abrir una conversación con un usuario específico -- se pasan
/// como `extra` al navegar a la ruta `/chat` (ver `core/router.dart`).
class ChatPageArgs {
  final String recipientId;
  final String recipientName;

  const ChatPageArgs({required this.recipientId, required this.recipientName});
}

/// Conversación 1 a 1 con cifrado E2EE real (RSA+AES, ver
/// `features/chat/data/crypto/`). MVP: sin lista de conversaciones ni
/// notificaciones push de mensajes nuevos -- se llega aquí directo desde el
/// botón "Chat" de un vendedor.
class ChatPage extends ConsumerWidget {
  final ChatPageArgs args;

  const ChatPage({super.key, required this.args});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(conversationControllerProvider(args.recipientId));
    final currentUserId = ref.watch(authControllerProvider).user?.id;

    return Scaffold(
      backgroundColor: VaultColors.background,
      appBar: AppBar(
        backgroundColor: VaultColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: VaultColors.textPrimary,
        title: Text(args.recipientName),
      ),
      body: Column(
        children: [
          Expanded(child: _MessagesBody(state: state, currentUserId: currentUserId)),
          _ChatInputBar(
            onSend: (text) => ref
                .read(conversationControllerProvider(args.recipientId).notifier)
                .send(text),
          ),
        ],
      ),
    );
  }
}

class _MessagesBody extends StatelessWidget {
  final ConversationState state;
  final String? currentUserId;

  const _MessagesBody({required this.state, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case ConversationStatus.initial:
      case ConversationStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case ConversationStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(VaultSpacing.xl),
            child: Text(
              state.errorMessage ?? 'Error al cargar la conversación',
              textAlign: TextAlign.center,
              style: const TextStyle(color: VaultColors.textSecondary),
            ),
          ),
        );
      case ConversationStatus.loaded:
        if (state.messages.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(VaultSpacing.xl),
              child: Text(
                'Escribe el primer mensaje para empezar la conversación.',
                textAlign: TextAlign.center,
                style: TextStyle(color: VaultColors.textSecondary),
              ),
            ),
          );
        }
        return ListView.builder(
          reverse: true,
          padding: const EdgeInsets.all(VaultSpacing.md),
          itemCount: state.messages.length,
          itemBuilder: (context, index) {
            final message = state.messages[state.messages.length - 1 - index];
            return _MessageBubble(
              message: message,
              isMine: message.senderId == currentUserId,
            );
          },
        );
    }
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isMine;

  const _MessageBubble({required this.message, required this.isMine});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    // Un mensaje propio de una sesión anterior no se puede volver a
    // descifrar (ver MessageEntity) -- se avisa en vez de mostrar vacío.
    final text = message.plainText ??
        (isMine ? 'Mensaje enviado (no se puede volver a mostrar)' : '⚠ No se pudo descifrar');

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: VaultSpacing.xs),
        padding: const EdgeInsets.symmetric(
          horizontal: VaultSpacing.md,
          vertical: VaultSpacing.sm,
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMine ? VaultColors.primary : VaultColors.surface,
          borderRadius: BorderRadius.circular(VaultRadius.card),
          border: isMine ? null : Border.all(color: VaultColors.divider),
        ),
        child: Text(
          text,
          style: tt.bodyMedium?.copyWith(
            color: isMine ? Colors.white : VaultColors.textPrimary,
            fontStyle: message.plainText == null ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ),
    );
  }
}

/// Barra inferior para escribir un mensaje, mismo lenguaje visual que
/// `CommentInputBar` (ver `features/comments/presentation/widgets.dart`).
class _ChatInputBar extends StatefulWidget {
  final ValueChanged<String> onSend;

  const _ChatInputBar({required this.onSend});

  @override
  State<_ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<_ChatInputBar> {
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
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: VaultSpacing.md, vertical: VaultSpacing.sm),
      decoration: const BoxDecoration(
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
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                decoration: InputDecoration(
                  hintText: 'Escribe un mensaje...',
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
                color: _canSend ? VaultColors.primary : VaultColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
