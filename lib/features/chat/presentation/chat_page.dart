import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/dimens.dart';
import '../../../core/theme.dart';
import '../../auth/presentation/providers.dart';
import '../../business/domain/entities.dart';
import '../../business/presentation/providers.dart';
import '../../servicerequests/presentation/send_to_service_sheet.dart';
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

    // Si la otra persona tiene un negocio registrado, se ofrece el botón
    // de "enviar a servicio/reparación" -- no tiene sentido para un chat
    // entre dos compradores comunes.
    final recipientBusiness = ref
        .watch(allBusinessesProvider)
        .maybeWhen(
          data: (businesses) =>
              businesses.where((b) => b.userId == args.recipientId).firstOrNull,
          orElse: () => null,
        );

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
          Expanded(
            child: _MessagesBody(
              state: state,
              currentUserId: currentUserId,
              otherUserId: args.recipientId,
            ),
          ),
          _ChatInputBar(
            business: recipientBusiness,
            onSend: (text) => ref
                .read(conversationControllerProvider(args.recipientId).notifier)
                .send(text),
          ),
        ],
      ),
    );
  }
}

class _MessagesBody extends ConsumerWidget {
  final ConversationState state;
  final String? currentUserId;
  final String otherUserId;

  const _MessagesBody({
    required this.state,
    required this.currentUserId,
    required this.otherUserId,
  });

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String messageId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar mensaje'),
        content: const Text(
          'Solo se elimina de tu lado, la otra persona lo sigue viendo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref
          .read(conversationControllerProvider(otherUserId).notifier)
          .deleteMessage(messageId);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              style: TextStyle(color: VaultColors.textSecondary),
            ),
          ),
        );
      case ConversationStatus.loaded:
        if (state.messages.isEmpty) {
          return Center(
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
              onLongPress: () => _confirmDelete(context, ref, message.id),
            );
          },
        );
    }
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isMine;
  final VoidCallback onLongPress;

  const _MessageBubble({
    required this.message,
    required this.isMine,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    // Un mensaje propio de una sesión anterior no se puede volver a
    // descifrar (ver MessageEntity) -- se avisa en vez de mostrar vacío.
    final text =
        message.plainText ??
        (isMine
            ? 'Mensaje enviado (no se puede volver a mostrar)'
            : '⚠ No se pudo descifrar');

    return GestureDetector(
      onLongPress: onLongPress,
      child: Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: VaultSpacing.xs),
          padding: const EdgeInsets.symmetric(
            horizontal: VaultSpacing.md,
            vertical: VaultSpacing.sm,
          ),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: isMine ? VaultColors.primary : VaultColors.surface,
            borderRadius: BorderRadius.circular(VaultRadius.card),
            border: isMine ? null : Border.all(color: VaultColors.divider),
          ),
          child: Text(
            text,
            style: tt.bodyMedium?.copyWith(
              color: isMine ? Colors.white : VaultColors.textPrimary,
              fontStyle: message.plainText == null
                  ? FontStyle.italic
                  : FontStyle.normal,
            ),
          ),
        ),
      ),
    );
  }
}

/// Barra inferior para escribir un mensaje, mismo lenguaje visual que
/// `CommentInputBar` (ver `features/comments/presentation/widgets.dart`).
class _ChatInputBar extends StatefulWidget {
  /// Devuelve `null` si se envió con éxito, o el mensaje de error si falló
  /// (ver `ConversationController.send`).
  final Future<String?> Function(String) onSend;

  /// Si la otra persona tiene un negocio registrado, se muestra el botón
  /// de "enviar a servicio/reparación" junto al campo de texto.
  final BusinessEntity? business;

  const _ChatInputBar({required this.onSend, this.business});

  @override
  State<_ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<_ChatInputBar> {
  final _controller = TextEditingController();
  bool _canSend = false;
  bool _sending = false;

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

  /// Antes esto vaciaba el campo de texto de inmediato sin esperar el
  /// resultado, así que un envío fallido (llave del destinatario no
  /// registrada, sin conexión, etc.) se veía idéntico a uno exitoso -- el
  /// texto desaparecía y el mensaje simplemente nunca llegaba, sin ningún
  /// aviso. Ahora se espera la respuesta: solo se limpia si se envió, y si
  /// falló se conserva el texto y se muestra el error.
  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    final error = await widget.onSend(text);
    if (!mounted) return;
    setState(() => _sending = false);
    if (error == null) {
      _controller.clear();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo enviar: $error')));
    }
  }

  Future<void> _openSendToService() async {
    final business = widget.business;
    if (business == null) return;

    final sent = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: VaultColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(VaultRadius.card),
        ),
      ),
      builder: (_) => SendToServiceSheet(
        businessId: business.id,
        businessName: business.name,
      ),
    );

    if (sent == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Solicitud enviada')));
    }
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
            if (widget.business != null)
              IconButton(
                onPressed: _openSendToService,
                tooltip: 'Enviar a servicio/reparación',
                icon: Icon(Icons.build_outlined, color: VaultColors.primary),
              ),
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
            _sending
                ? const Padding(
                    padding: EdgeInsets.all(VaultSpacing.sm),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
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
