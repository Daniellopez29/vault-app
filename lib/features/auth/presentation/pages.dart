import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/enums.dart';
import '../../../../core/router.dart';
import '../../../../core/theme.dart';
import '../../home/presentation/feed_tab.dart';
import '../../home/presentation/widgets.dart';
import '../../profile/presentation/profile_tab.dart';
import '../../reviews/presentation/reviews_tab.dart';
import '../../services/presentation/services_tab.dart';
import '../../../core/screen_security.dart';
import 'providers.dart';
import 'widgets.dart';
import '../../marketplace/presentation/shop_tab.dart';
import '../../cart/presentation/cart_tab.dart';

/// Pantalla de bienvenida: dos caminos claros (crear cuenta / iniciar sesión).
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child:
            Image.asset('assets/images/fondologin.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.white.withValues(alpha: 0.55)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'VAULT',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: VaultColors.primary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Image.asset('assets/images/logo_login.png', height: 140),
                  const SizedBox(height: 24),
                  const Text(
                    'Un sistema inteligente que centraliza, monitorea y optimiza '
                        'el ciclo de vida de tus activos personales de valor para '
                        'asegurar su preservación, autenticidad y rendimiento en el mercado.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: VaultColors.primary,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.push(AppRoutes.roleSelection),
                      child: const Text('Crear una cuenta'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => context.push(AppRoutes.signIn),
                      child: const Text('Iniciar sesión'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.push(AppRoutes.legal),
                    child: const Text(
                      'Términos de Privacidad | Política de Uso',
                      style: TextStyle(
                        fontSize: 12,
                        color: VaultColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pantalla de inicio de sesión (correo/contraseña + Google).
class SignInPage extends ConsumerWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: VaultColors.primary,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child:
            Image.asset('assets/images/fondologin.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.white.withValues(alpha: 0.75)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'VAULT',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: VaultColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '¡Bienvenido otra vez!',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: VaultColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tu colección premium, bajo control inteligente.',
                    style: TextStyle(
                      fontSize: 14,
                      color: VaultColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  const LoginForm(),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.push(AppRoutes.legal),
                    child: const Text(
                      'Términos de Privacidad | Política de Uso',
                      style: TextStyle(
                        fontSize: 12,
                        color: VaultColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 1;

  List<Widget> _buildPages(UserRole role) {
    switch (role) {
      case UserRole.user:
        return const [
          ShopTab(),
          FeedTab(),
          CartTab(),                    // ← antes: PlaceholderView(title: 'Carrito')
          ProfileTab(),
        ];
      case UserRole.seller:
        return const [
          ShopTab(),
          FeedTab(),
          PlaceholderView(title: 'Ventas'),
          ProfileTab(),
        ];
      case UserRole.restorer:
        return const [
          FeedTab(),
          ServicesTab(),
          ReviewsTab(),
          ProfileTab(),
        ];
      case UserRole.service:
        return const [
          FeedTab(),
          ServicesTab(),
          ReviewsTab(),
          ProfileTab(),
        ];
    }
  }

  List<_NavItem> _buildNavItems(UserRole role) {
    switch (role) {
      case UserRole.user:
        return const [
          _NavItem(icon: Icons.storefront_outlined,   label: 'Shop'),
          _NavItem(icon: Icons.home_outlined,         label: 'Feed'),
          _NavItem(icon: Icons.add,                   label: ''),
          _NavItem(icon: Icons.shopping_bag_outlined, label: 'Cart'),
          _NavItem(icon: Icons.person_outline,        label: 'Perfil'),
        ];
      case UserRole.seller:
        return const [
          _NavItem(icon: Icons.storefront_outlined,   label: 'Shop'),
          _NavItem(icon: Icons.home_outlined,         label: 'Feed'),
          _NavItem(icon: Icons.add,                   label: ''),
          _NavItem(icon: Icons.sell_outlined,         label: 'Ventas'),
          _NavItem(icon: Icons.person_outline,        label: 'Perfil'),
        ];
      case UserRole.restorer:
        return const [
          _NavItem(icon: Icons.home_outlined,  label: 'Feed'),
          _NavItem(icon: Icons.build_outlined, label: 'Servicios'),
          _NavItem(icon: Icons.add,            label: ''),
          _NavItem(icon: Icons.star_outline,   label: 'Reseñas'),
          _NavItem(icon: Icons.person_outline, label: 'Perfil'),
        ];
      case UserRole.service:
        return const [
          _NavItem(icon: Icons.home_outlined,  label: 'Feed'),
          _NavItem(icon: Icons.build_outlined, label: 'Servicios'),
          _NavItem(icon: Icons.add,            label: ''),
          _NavItem(icon: Icons.star_outline,   label: 'Reseñas'),
          _NavItem(icon: Icons.person_outline, label: 'Perfil'),
        ];
    }
  }

  void _onAddPressed() {
    final role = ref.read(authControllerProvider).user?.role ?? UserRole.user;
    if (role == UserRole.user) {
      context.push(AppRoutes.registerAsset);
      return;
    }
    final message = switch (role) {
      UserRole.seller   => 'Próximamente: Publicar activo en venta',
      UserRole.restorer => 'Próximamente: Publicar nuevo servicio',
      UserRole.service  => 'Próximamente: Publicar servicio de tu negocio',
      UserRole.user     => '', // ya manejado arriba
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(authControllerProvider).user?.role ?? UserRole.user;
    final pages = _buildPages(role);
    final navItems = _buildNavItems(role);

    if (_currentIndex >= pages.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: _currentIndex, children: pages),
      ),
      bottomNavigationBar: VaultBottomNavBar(
        currentIndex: _currentIndex,
        onTabSelected: (navIndex) {
          final pageIndex = navIndex > 2 ? navIndex - 1 : navIndex;
          setState(() => _currentIndex = pageIndex);
        },
        onAddPressed: _onAddPressed,
        navItems: navItems,
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}