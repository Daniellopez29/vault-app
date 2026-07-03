import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/enums.dart';
import '../../../../core/router.dart';
import '../../../../core/theme.dart';
import '../../home/presentation/feed_tab.dart';
import '../../home/presentation/widgets.dart';
import '../../profile/presentation/profile_tab.dart';
import '../../reviews/presentation/reviews_tab.dart';
import '../../services/presentation/services_tab.dart';
import 'providers.dart';
import 'widgets.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: [
          _WelcomePage(
            onLoginWithEmail: () => _pageController.animateToPage(
              1,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
          ),
          const _LoginFormPage(),
        ],
      ),
    );
  }
}

Future<void> _launchPrivacyPolicy() async {
  final url = Uri.parse('https://daniellopez29.github.io/vault-privacy-policy');
  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }
}

class _WelcomePage extends ConsumerWidget {
  final VoidCallback onLoginWithEmail;

  const _WelcomePage({required this.onLoginWithEmail});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading =
        ref.watch(authControllerProvider).status == AuthStatus.loading;
    final errorMessage = ref.watch(authControllerProvider).errorMessage;

    ref.listen(authControllerProvider, (_, next) {
      if (next.status == AuthStatus.authenticated) {
        context.go(AppRoutes.home);
      } else if (next.status == AuthStatus.roleSelection) {
        context.go(AppRoutes.roleSelection);
      }
    });

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/images/fondologin.png', fit: BoxFit.cover),
        ),
        Positioned.fill(
          child: Container(color: Colors.white.withValues(alpha: 0.30)),
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
                if (errorMessage != null) ...[
                  Text(
                    errorMessage,
                    style: const TextStyle(color: VaultColors.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () => ref
                        .read(authControllerProvider.notifier)
                        .loginWithGoogle(),
                    icon: isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const FaIcon(
                      FontAwesomeIcons.google,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: const Text('Inicia con Google'),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '-ó-',
                  style: TextStyle(
                    color: VaultColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : onLoginWithEmail,
                    icon: const Icon(Icons.email_outlined, size: 20),
                    label: const Text('Inicia con Correo'),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _launchPrivacyPolicy,
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
    );
  }
}

class _LoginFormPage extends ConsumerWidget {
  const _LoginFormPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/images/fondologin.png', fit: BoxFit.cover),
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
                const SizedBox(height: 16),
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
                  onPressed: _launchPrivacyPolicy,
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
      case UserRole.restorer:
        return const [
          FeedTab(),
          ServicesTab(),
          PlaceholderView(title: 'Carrito'),
          ReviewsTab(),
          ProfileTab(),
        ];
      case UserRole.general:
      case UserRole.collector:
        return const [
          PlaceholderView(title: 'Shop'),
          FeedTab(),
          PlaceholderView(title: 'Carrito'),
          ProfileTab(),
        ];
    }
  }

  List<_NavItem> _buildNavItems(UserRole role) {
    switch (role) {
      case UserRole.restorer:
        return const [
          _NavItem(icon: Icons.home_outlined,         label: 'Feed'),
          _NavItem(icon: Icons.build_outlined,        label: 'Servicios'),
          _NavItem(icon: Icons.add,                   label: ''),
          _NavItem(icon: Icons.star_outline,          label: 'Reseñas'),
          _NavItem(icon: Icons.person_outline,        label: 'Perfil'),
        ];
      case UserRole.general:
      case UserRole.collector:
        return const [
          _NavItem(icon: Icons.storefront_outlined,   label: 'Shop'),
          _NavItem(icon: Icons.home_outlined,         label: 'Feed'),
          _NavItem(icon: Icons.add,                   label: ''),
          _NavItem(icon: Icons.shopping_bag_outlined, label: 'Cart'),
          _NavItem(icon: Icons.person_outline,        label: 'Perfil'),
        ];
    }
  }

  void _onAddPressed() {
    final role =
        ref.read(authControllerProvider).user?.role ?? UserRole.general;
    final message = role == UserRole.restorer
        ? 'Próximamente: Publicar nuevo servicio'
        : 'Próximamente: Registrar nuevo activo';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role =
        ref.watch(authControllerProvider).user?.role ?? UserRole.general;
    final pages = _buildPages(role);
    final navItems = _buildNavItems(role);

    if (_currentIndex >= pages.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
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