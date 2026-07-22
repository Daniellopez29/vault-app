import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/dimens.dart';
import '../../../core/router.dart';
import '../../../core/theme.dart';

/// Accesos a las secciones propias del usuario, dentro del Perfil.
///
/// Viven aquí (y no en el nav) para que la navegación principal sea igual
/// para todos los roles. Cualquiera puede vender u ofrecer servicios, así
/// que los accesos se muestran a todos.
class ProfileActions extends StatelessWidget {
  const ProfileActions({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: VaultSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mi actividad', style: tt.titleMedium),
          const SizedBox(height: VaultSpacing.sm),
          Container(
            decoration: BoxDecoration(
              color: VaultColors.surface,
              borderRadius: VaultRadius.cardBorder,
              border: Border.all(color: VaultColors.divider),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _ActionRow(
                  icon: Icons.storefront_outlined,
                  label: 'Comercio',
                  subtitle: 'Tus productos en venta y tu negocio',
                  onTap: () => context.push(AppRoutes.commerce),
                ),
                const Divider(height: 1, color: VaultColors.divider),
                _ActionRow(
                  icon: Icons.build_outlined,
                  label: 'Servicios',
                  subtitle: 'Servicios que ofreces',
                  onTap: () => context.push(AppRoutes.services),
                ),
                const Divider(height: 1, color: VaultColors.divider),
                _ActionRow(
                  icon: Icons.star_outline,
                  label: 'Reseñas',
                  subtitle: 'Valoraciones que has recibido',
                  onTap: () => context.push(AppRoutes.reviews),
                ),
                const Divider(height: 1, color: VaultColors.divider),
                _ActionRow(
                  icon: Icons.insights_outlined,
                  label: 'Estadísticas',
                  subtitle: 'Resumen de tu colección',
                  onTap: () => context.push(AppRoutes.stats),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: VaultSpacing.md,
          vertical: VaultSpacing.md,
        ),
        child: Row(
          children: [
            Icon(icon, color: VaultColors.primary, size: VaultIconSize.md),
            const SizedBox(width: VaultSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: tt.titleSmall),
                  Text(
                    subtitle,
                    style: tt.labelSmall?.copyWith(
                      color: VaultColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: VaultColors.textSecondary,
              size: VaultIconSize.md,
            ),
          ],
        ),
      ),
    );
  }
}
