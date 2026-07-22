import 'package:flutter/material.dart';
import '../../../core/dimens.dart';
import '../../../core/theme.dart';

/// Pantalla de chat. Placeholder por ahora: el chat en tiempo real (con
/// cifrado E2EE) llegará más adelante. El acceso desde el header ya queda
/// funcional para no dejar el ícono muerto.
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VaultColors.background,
      appBar: AppBar(
        backgroundColor: VaultColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text("Mensajes"),
        foregroundColor: VaultColors.textPrimary,
      ),
      body: const _EmptyState(
        icon: Icons.forum_outlined,
        title: "Chat próximamente",
        message: "Pronto podrás conversar con vendedores y compradores desde aquí.",
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
