import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/dimens.dart';
import '../../../core/router.dart';
import '../../../core/theme.dart';
import '../../../core/time_ago.dart';
import '../domain/entities.dart';
import 'chat_page.dart';
import 'providers.dart';

/// Bandeja de conversaciones: una fila por cada persona con la que hay al
/// menos un mensaje, ordenadas por la más reciente. Es el punto de entrada
/// al chat desde el ícono de mensajes en el Feed y el Shop -- antes era un
/// SnackBar de "próximamente" porque no existía forma de saber con quién
/// había conversaciones sin este listado.
class ConversationsListPage extends ConsumerWidget {
  const ConversationsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(conversationsControllerProvider);

    return Scaffold(
      backgroundColor: VaultColors.background,
      appBar: AppBar(title: const Text('Mensajes'), centerTitle: true),
      body: switch (state.status) {
        ConversationsStatus.initial || ConversationsStatus.loading =>
          const Center(child: CircularProgressIndicator()),
        ConversationsStatus.error => Center(
          child: Padding(
            padding: const EdgeInsets.all(VaultSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.errorMessage ?? 'No se pudieron cargar tus mensajes',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: VaultColors.textSecondary),
                ),
                const SizedBox(height: VaultSpacing.md),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(conversationsControllerProvider.notifier).load(),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
        ConversationsStatus.loaded =>
          state.conversations.isEmpty
              ? const _EmptyConversations()
              : RefreshIndicator(
                  onRefresh: () =>
                      ref.read(conversationsControllerProvider.notifier).load(),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      vertical: VaultSpacing.sm,
                    ),
                    itemCount: state.conversations.length,
                    separatorBuilder: (_, _) => Divider(
                      height: 1,
                      color: VaultColors.divider,
                      indent: 72,
                    ),
                    itemBuilder: (context, index) {
                      final conversation = state.conversations[index];
                      return Dismissible(
                        key: ValueKey(conversation.otherUserId),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (_) => showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Eliminar conversación'),
                            content: const Text(
                              'Solo se elimina de tu lado, la otra persona la sigue viendo.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text('Eliminar'),
                              ),
                            ],
                          ),
                        ),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(
                            horizontal: VaultSpacing.md,
                          ),
                          color: Colors.red.shade400,
                          child: const Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                          ),
                        ),
                        onDismissed: (_) => ref
                            .read(conversationsControllerProvider.notifier)
                            .deleteConversation(conversation.otherUserId),
                        child: _ConversationTile(conversation: conversation),
                      );
                    },
                  ),
                ),
      },
    );
  }
}

class _EmptyConversations extends StatelessWidget {
  const _EmptyConversations();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(VaultSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: VaultIconSize.xl,
              color: VaultColors.textSecondary,
            ),
            const SizedBox(height: VaultSpacing.md),
            Text(
              'Todavía no tienes conversaciones',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: VaultSpacing.xs),
            Text(
              'Escribe a un vendedor o a un negocio desde su publicación '
              'para empezar a chatear.',
              textAlign: TextAlign.center,
              style: TextStyle(color: VaultColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final ConversationSummaryEntity conversation;

  const _ConversationTile({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final unread = conversation.unreadCount > 0;
    final preview = conversation.lastMessage.plainText ?? 'Mensaje cifrado';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: VaultSpacing.md,
        vertical: VaultSpacing.xs,
      ),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: VaultColors.background,
        backgroundImage: conversation.otherUserAvatarUrl.isNotEmpty
            ? NetworkImage(conversation.otherUserAvatarUrl)
            : null,
        child: conversation.otherUserAvatarUrl.isEmpty
            ? Icon(Icons.person_outline, color: VaultColors.textSecondary)
            : null,
      ),
      title: Text(
        conversation.otherUserName,
        style: tt.titleSmall?.copyWith(
          fontWeight: unread ? FontWeight.bold : FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        preview,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: tt.bodyMedium?.copyWith(
          color: unread ? VaultColors.textPrimary : VaultColors.textSecondary,
          fontWeight: unread ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            timeAgoFrom(conversation.lastMessage.timestamp.toIso8601String()),
            style: tt.labelSmall?.copyWith(color: VaultColors.textSecondary),
          ),
          if (unread) ...[
            const SizedBox(height: VaultSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: VaultColors.accent,
                borderRadius: BorderRadius.circular(VaultRadius.sm),
              ),
              child: Text(
                '${conversation.unreadCount}',
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ],
        ],
      ),
      onTap: () => context.push(
        AppRoutes.chat,
        extra: ChatPageArgs(
          recipientId: conversation.otherUserId,
          recipientName: conversation.otherUserName,
        ),
      ),
    );
  }
}
