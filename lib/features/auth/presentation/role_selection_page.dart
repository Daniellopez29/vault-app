import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/enums.dart';
import '../../../../core/router.dart';
import '../../../../core/screen_security.dart';
import '../../../../core/theme.dart';
import 'providers.dart';

/// Las 3 formas de empezar a usar la app. No son lo mismo que [UserRole]:
/// "Negocio" no elige entre Restaurador/Servicio aquí -- eso se decide con
/// la categoría dentro de la pantalla de registrar negocio, que también
/// corrige el rol final. El rol que se manda al crear la cuenta es solo
/// un valor inicial razonable.
enum _SignupOption { collector, seller, business }

extension _SignupOptionUI on _SignupOption {
  String get title {
    switch (this) {
      case _SignupOption.collector: return 'Coleccionista';
      case _SignupOption.seller:    return 'Vendedor';
      case _SignupOption.business:  return 'Negocio';
    }
  }

  String get description {
    switch (this) {
      case _SignupOption.collector:
        return 'Administra tu colección, historial y comunidad.';
      case _SignupOption.seller:
        return 'Registra un artículo y ponlo a la venta.';
      case _SignupOption.business:
        return 'Registra tu taller o negocio de mantenimiento/reparación.';
    }
  }

  IconData get icon {
    switch (this) {
      case _SignupOption.collector: return Icons.person_outline;
      case _SignupOption.seller:    return Icons.sell_outlined;
      case _SignupOption.business:  return Icons.storefront_outlined;
    }
  }

  /// Rol inicial de la cuenta. Para "Negocio" se deja el rol base
  /// ("usuario", el mismo default de la base de datos) porque todavía no
  /// eligió categoría -- register_business_page.dart recién ahí asigna
  /// restaurador/servicio según lo que elija.
  UserRole get initialRole {
    switch (this) {
      case _SignupOption.collector: return UserRole.user;
      case _SignupOption.seller:    return UserRole.seller;
      case _SignupOption.business:  return UserRole.user;
    }
  }

  /// A dónde ir justo después de crear la cuenta.
  String get destination {
    switch (this) {
      case _SignupOption.collector: return AppRoutes.home;
      case _SignupOption.seller:    return AppRoutes.registerAsset;
      case _SignupOption.business:  return AppRoutes.registerBusiness;
    }
  }
}

class RoleSelectionPage extends ConsumerStatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  ConsumerState<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends ConsumerState<RoleSelectionPage> {
  @override
  void initState() {
    super.initState();
    ScreenSecurity.enable();
  }

  @override
  void dispose() {
    ScreenSecurity.disable();
    super.dispose();
  }

  /// Al elegir una opción hay dos caminos:
  /// - Flujo Google: solo llega aquí una cuenta recién creada (ver
  ///   AuthController.loginWithGoogle, que ahora filtra por is_new_user) →
  ///   guarda el rol y esta misma pantalla redirige a Home (ver build()).
  /// - Flujo registro por correo: aún no hay cuenta → va al formulario con
  ///   el rol inicial y el destino final ya decididos.
  void _onOptionSelected(BuildContext context, WidgetRef ref, _SignupOption option) {
    final status = ref.read(authControllerProvider).status;
    if (status == AuthStatus.roleSelection) {
      ref.read(authControllerProvider.notifier).saveRole(option.initialRole);
      return;
    }
    context.push(
      AppRoutes.register,
      extra: RegisterFlowArgs(role: option.initialRole, destination: option.destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final isLoading =
        ref.watch(authControllerProvider).status == AuthStatus.loading;

    // Solo aplica al flujo de Google (saveRole se llama estando ya en esta
    // pantalla). El flujo de registro por correo redirige desde
    // RegisterFormPage, que sabe a qué destino ir según la opción elegida.
    ref.listen(authControllerProvider, (_, next) {
      if (next.status == AuthStatus.authenticated) {
        context.go(AppRoutes.home);
      }
    });

    return Scaffold(
      backgroundColor: VaultColors.background,
      // Sin título -- solo para poder volver a Login cuando esta pantalla se
      // alcanzó con context.push (registro por correo). Cuando se llega vía
      // context.go (flujo de Google, sin pantalla anterior en el stack),
      // AppBar oculta la flecha sola porque Navigator.canPop es false.
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: VaultColors.primary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
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
              ..._SignupOption.values.map(
                    (option) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _OptionCard(
                    option: option,
                    isLoading: isLoading,
                    onTap: () => _onOptionSelected(context, ref, option),
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

class _OptionCard extends StatelessWidget {
  final _SignupOption option;
  final bool isLoading;
  final VoidCallback onTap;

  const _OptionCard({
    required this.option,
    required this.isLoading,
    required this.onTap,
  });

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
              child: Icon(option.icon, color: VaultColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: tt.titleLarge?.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    option.description,
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
