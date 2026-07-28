import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/dimens.dart';
import '../../../core/theme.dart';
import '../../../core/time_ago.dart';
import '../domain/entities.dart';
import 'providers.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsControllerProvider);

    return Scaffold(
      backgroundColor: VaultColors.background,
      appBar: AppBar(
        backgroundColor: VaultColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text("Notificaciones"),
        foregroundColor: VaultColors.textPrimary,
      ),
      body: _Body(state: state),
    );
  }
}

class _Body extends ConsumerWidget {
  final NotificationsState state;

  const _Body({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (state.status) {
      case NotificationsStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case NotificationsStatus.error:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(state.errorMessage ?? 'Error al cargar las notificaciones'),
              const SizedBox(height: VaultSpacing.md),
              TextButton(
                onPressed: () => ref.read(notificationsControllerProvider.notifier).load(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        );
      case NotificationsStatus.loaded:
        if (state.notifications.isEmpty) {
          return const _EmptyState(
            icon: Icons.notifications_none,
            title: "Sin notificaciones",
            message: "Aquí verás tus avisos y novedades cuando lleguen.",
          );
        }
        return RefreshIndicator(
          onRefresh: () => ref.read(notificationsControllerProvider.notifier).load(),
          child: ListView.builder(
            padding: const EdgeInsets.all(VaultSpacing.md),
            itemCount: state.notifications.length,
            itemBuilder: (context, index) {
              final n = state.notifications[index];
              return Dismissible(
                key: ValueKey(n.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: VaultSpacing.md),
                  margin: const EdgeInsets.only(bottom: VaultSpacing.sm),
                  decoration: BoxDecoration(
                    color: Colors.red.shade400,
                    borderRadius: VaultRadius.cardBorder,
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),
                onDismissed: (_) =>
                    ref.read(notificationsControllerProvider.notifier).delete(n.id),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: VaultSpacing.sm),
                  child: _NotificationTile(
                    notification: n,
                    onTap: () =>
                        ref.read(notificationsControllerProvider.notifier).markAsRead(n.id),
                  ),
                ),
              );
            },
          ),
        );
    }
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  /// `type` viene de `api/`'s `allowedNotificationTypes`: servicio,
  /// reparacion, venta, blockchain, comunidad.
  IconData get _icon {
    switch (notification.type) {
      case 'servicio':
      case 'reparacion':
        return Icons.build_outlined;
      case 'venta':
        return Icons.storefront_outlined;
      case 'blockchain':
        return Icons.verified_outlined;
      case 'comunidad':
        return Icons.dynamic_feed_outlined;
      case 'suscripcion':
        return Icons.workspace_premium_outlined;
      default:
        return Icons.notifications_none;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: VaultRadius.cardBorder,
      child: Container(
        padding: const EdgeInsets.all(VaultSpacing.md),
        decoration: BoxDecoration(
          color: notification.read ? VaultColors.surface : VaultColors.primary.withValues(alpha: 0.06),
          borderRadius: VaultRadius.cardBorder,
          border: Border.all(color: VaultColors.divider),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_icon, color: VaultColors.primary),
            const SizedBox(width: VaultSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: tt.titleSmall?.copyWith(
                      fontWeight: notification.read ? FontWeight.normal : FontWeight.w700,
                    ),
                  ),
                  if (notification.body.isNotEmpty) ...[
                    const SizedBox(height: VaultSpacing.xs),
                    Text(notification.body, style: const TextStyle(color: VaultColors.textSecondary)),
                  ],
                  const SizedBox(height: VaultSpacing.xs),
                  Text(
                    timeAgoFrom(notification.createdAt),
                    style: const TextStyle(color: VaultColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (!notification.read)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(color: VaultColors.primary, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(VaultSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: VaultIconSize.xl, color: VaultColors.textSecondary),
            const SizedBox(height: VaultSpacing.lg),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: VaultColors.textPrimary,
              ),
            ),
            const SizedBox(height: VaultSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: VaultColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
