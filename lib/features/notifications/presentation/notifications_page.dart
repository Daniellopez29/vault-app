import 'package:flutter/material.dart';
import '../../../core/dimens.dart';
import '../../../core/theme.dart';

/// Pantalla de notificaciones. Por ahora es un placeholder: la lista real
/// llegará cuando el backend de notificaciones esté disponible. Solo cambia
/// esta capa; la navegación y el acceso desde el header ya quedan listos.
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VaultColors.background,
      appBar: AppBar(
        backgroundColor: VaultColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text("Notificaciones"),
        foregroundColor: VaultColors.textPrimary,
      ),
      body: const _EmptyState(
        icon: Icons.notifications_none,
        title: "Sin notificaciones",
        message: "Aquí verás tus avisos y novedades cuando lleguen.",
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
