import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api_client.dart';
import '../../../core/router.dart';
import '../../../core/theme.dart';
import '../../auth/presentation/providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final user = ref.watch(authControllerProvider).user;

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        children: [
          _SettingsSection(
            title: 'Cuenta',
            children: [
              _SettingsTile(
                icon: Icons.person_outline,
                label: 'Editar nombre',
                onTap: () => _showEditNameDialog(context, ref, user?.fullName),
              ),
              _SettingsTile(
                icon: Icons.lock_outline,
                label: 'Cambiar contraseña',
                onTap: () => _showChangePasswordDialog(context, ref),
              ),
              _SettingsTile(
                icon: Icons.delete_outline,
                label: 'Eliminar cuenta',
                color: VaultColors.error,
                onTap: () => _showDeleteAccountDialog(context, ref),
              ),
            ],
          ),
            _SettingsSection(
              title: 'Compras',
              children: [
                _SettingsTile(
                  icon: Icons.location_on_outlined,
                  label: 'Direcciones de envío',
                  onTap: () => context.push(AppRoutes.addresses),
                ),
              ],
            ),
          _SettingsSection(
            title: 'Negocio',
            children: [
              _SettingsTile(
                icon: Icons.storefront_outlined,
                label: 'Registra tu negocio',
                onTap: () => context.push(AppRoutes.registerBusiness),
              ),
            ],
          ),
          _SettingsSection(
            title: 'Avanzado',
            children: [
              _SettingsTile(
                icon: Icons.dns_outlined,
                label: 'Servidor',
                trailing: Text(
                  ApiConfig.baseUrl.replaceFirst('http://', '').replaceFirst('/api/v1', ''),
                  style: tt.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => _showServerUrlDialog(context),
              ),
            ],
          ),
          _SettingsSection(
            title: 'Soporte',
            children: [
              _SettingsTile(
                icon: Icons.article_outlined,
                label: 'Términos y condiciones',
                onTap: () => context.push(AppRoutes.legal, extra: 0),
              ),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                label: 'Política de privacidad',
                onTap: () => context.push(AppRoutes.legal, extra: 1),
              ),
              _SettingsTile(
                icon: Icons.info_outline,
                label: 'Versión de la app',
                trailing: Text('1.0.0', style: tt.bodyMedium),
                onTap: null,
              ),
            ],
          ),
          _SettingsSection(
            title: 'Sesión',
            children: [
              _SettingsTile(
                icon: Icons.logout,
                label: 'Cerrar sesión',
                color: VaultColors.error,
                onTap: () => _showLogoutDialog(context, ref),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog(
      BuildContext context, WidgetRef ref, String? currentName) {
    final controller = TextEditingController(text: currentName ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar nombre'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nombre completo'),
          textCapitalization: TextCapitalization.words,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty) return;
              Navigator.of(context).pop();
              final success = await ref
                  .read(authControllerProvider.notifier)
                  .updateDisplayName(newName);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Nombre actualizado correctamente')),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  /// Deja escribir manualmente la URL del backend -- necesario al probar
  /// desde un celular físico: "localhost" ahí es el celular mismo, nunca
  /// la computadora donde corre el API. Debe ser la IP LAN de esa máquina
  /// (ambos dispositivos en la misma red Wi-Fi), p.ej. http://192.168.x.x:8080/api/v1
  void _showServerUrlDialog(BuildContext context) {
    final controller = TextEditingController(text: ApiConfig.baseUrl);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Dirección del servidor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Usa la IP local de la computadora donde corre el backend '
              '(ambos en la misma red Wi-Fi), no "localhost".',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'URL base',
                hintText: 'http://192.168.1.10:8080/api/v1',
              ),
              keyboardType: TextInputType.url,
              autocorrect: false,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await ApiConfig.setOverride(null);
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Restablecer'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await ApiConfig.setOverride(controller.text.trim());
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Servidor actualizado')),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cambiar contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(labelText: 'Nueva contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPasswordController,
              decoration:
              const InputDecoration(labelText: 'Confirmar contraseña'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final newPassword = newPasswordController.text.trim();
              final confirmPassword = confirmPasswordController.text.trim();

              if (newPassword.isEmpty || confirmPassword.isEmpty) return;

              if (newPassword != confirmPassword) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Las contraseñas no coinciden')),
                );
                return;
              }

              if (newPassword.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'La contraseña debe tener al menos 6 caracteres')),
                );
                return;
              }

              Navigator.of(context).pop();
              final success = await ref
                  .read(authControllerProvider.notifier)
                  .updatePassword(newPassword);

              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Contraseña actualizada correctamente')),
                );
              } else if (!success && context.mounted) {
                final error =
                    ref.read(authControllerProvider).errorMessage ?? 'Error';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(error)),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(authControllerProvider.notifier).logout();
              context.go(AppRoutes.login);
            },
            child: Text('Cerrar sesión',
                style: TextStyle(color: VaultColors.error)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar cuenta'),
        content: const Text(
            '¿Estás seguro? Esta acción es permanente y no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await ref
                  .read(authControllerProvider.notifier)
                  .deleteAccount();
              if (success && context.mounted) {
                context.go(AppRoutes.login);
              }
            },
            child:
            Text('Eliminar', style: TextStyle(color: VaultColors.error)),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title.toUpperCase(),
            style: tt.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: VaultColors.textSecondary,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: VaultColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.color,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final tileColor = color ?? VaultColors.textPrimary;

    return ListTile(
      leading: Icon(icon, color: tileColor, size: 22),
      title: Text(label, style: tt.bodyLarge?.copyWith(color: tileColor)),
      trailing: trailing != null
          ? ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 160),
              child: trailing,
            )
          :
          (onTap != null
              ? Icon(Icons.chevron_right,
              color: VaultColors.textSecondary, size: 20)
              : null),
      onTap: onTap,
    );
  }
}
