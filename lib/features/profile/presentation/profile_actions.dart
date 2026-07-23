import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/dimens.dart';
import '../../../core/router.dart';
import '../../../core/theme.dart';

/// Accesos rapidos a las secciones propias del usuario, dentro del Perfil.
///
/// Se presentan como una fila compacta para no competir con el contenido
/// principal (los activos). Viven aqui y no en el nav para que la navegacion
/// principal sea igual para todos los roles.
class ProfileActions extends StatelessWidget {
  const ProfileActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: VaultColors.divider),
          bottom: BorderSide(color: VaultColors.divider),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: VaultSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _QuickAction(
            icon: Icons.sell_outlined,
            label: 'Comercio',
            onTap: () => context.push(AppRoutes.commerce),
          ),
          _QuickAction(
            icon: Icons.build_outlined,
            label: 'Servicios',
            onTap: () => context.push(AppRoutes.services),
          ),
          _QuickAction(
            icon: Icons.star_outline,
            label: 'Reseñas',
            onTap: () => context.push(AppRoutes.reviews),
          ),
          _QuickAction(
            icon: Icons.insights_outlined,
            label: 'Datos',
            onTap: () => context.push(AppRoutes.stats),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(VaultRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: VaultSpacing.md,
          vertical: VaultSpacing.xs,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: VaultIconSize.lg, color: VaultColors.primary),
            const SizedBox(height: VaultSpacing.xs),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: VaultColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
