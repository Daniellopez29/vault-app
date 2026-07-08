import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/enums.dart';
import '../../../../core/router.dart';
import '../../../../core/theme.dart';
import 'providers.dart';

class RoleSelectionPage extends ConsumerWidget {
  const RoleSelectionPage({super.key});

  /// Al elegir un rol hay dos caminos:
  /// - Flujo Google: el usuario ya existe (estado roleSelection) → guarda el rol.
  /// - Flujo registro por correo: aún no hay cuenta → va al formulario con el rol.
  void _onRoleSelected(BuildContext context, WidgetRef ref, UserRole role) {
    final status = ref.read(authControllerProvider).status;
    if (status == AuthStatus.roleSelection) {
      ref.read(authControllerProvider.notifier).saveRole(role);
    } else {
      context.push(AppRoutes.register, extra: role);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final isLoading =
        ref.watch(authControllerProvider).status == AuthStatus.loading;

    ref.listen(authControllerProvider, (_, next) {
      if (next.status == AuthStatus.authenticated) {
        context.go(AppRoutes.home);
      }
    });

    return Scaffold(
      backgroundColor: VaultColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              Text(
                'VAULT',
                style: tt.headlineLarge?.copyWith(fontSize: 28),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '¿Cómo usarás la app?',
                style: tt.headlineMedium?.copyWith(fontSize: 22),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Selecciona tu perfil para personalizar tu experiencia.',
                style: tt.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ...UserRole.values.map(
                    (role) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _RoleCard(
                    role: role,
                    isLoading: isLoading,
                    onTap: () => _onRoleSelected(context, ref, role),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final UserRole role;
  final bool isLoading;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.isLoading,
    required this.onTap,
  });

  IconData get _icon {
    switch (role) {
      case UserRole.user:     return Icons.person_outline;
      case UserRole.seller:   return Icons.sell_outlined;
      case UserRole.restorer: return Icons.build_outlined;
      case UserRole.service:  return Icons.storefront_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: VaultColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: VaultColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: VaultColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_icon, color: VaultColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role.displayName,
                    style: tt.titleLarge?.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role.description,
                    style: tt.bodyMedium?.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: VaultColors.textSecondary),
          ],
        ),
      ),
    );
  }
}