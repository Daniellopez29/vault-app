import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'providers.dart';
import 'widgets.dart';
import '../../home/presentation/widgets.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

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
        onPageChanged: (index) => setState(() => _currentPage = index),
        children: [
          _WelcomePage(onLoginWithEmail: () {
            _pageController.animateToPage(1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut);
          }),
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

class _WelcomePage extends StatelessWidget {
  final VoidCallback onLoginWithEmail;
  const _WelcomePage({required this.onLoginWithEmail});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/images/fondologin.png', fit: BoxFit.cover),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.65),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.topLeft,
                  child: Text('VAULT',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2)),
                ),
                const Spacer(),
                Image.asset('assets/images/logo_login.png', height: 140),
                const SizedBox(height: 24),
                const Text(
                  'Un sistema inteligente que centraliza, monitorea y optimiza el ciclo de vida de tus activos personales de valor para asegurar su preservación, autenticidad y rendimiento en el mercado.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.g_mobiledata, size: 28, color: Colors.white),
                    label: const Text('Inicia con Google',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D2D3A),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('-ó-', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onLoginWithEmail,
                    icon: const Icon(Icons.email_outlined, size: 24, color: Colors.white),
                    label: const Text('Inicia con Correo',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D2D3A),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _launchPrivacyPolicy,
                  child: const Text(
                    'Términos de Privacidad | Política de Uso',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
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
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.65),
            ),
          ),
        ),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                const Text('VAULT',
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2),
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                const Text('¡Bienvenido otra vez!',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
                const SizedBox(height: 4),
                const Text('Tu colección premium, bajo control inteligente.',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                    textAlign: TextAlign.center),
                const SizedBox(height: 40),
                const LoginForm(),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _launchPrivacyPolicy,
                  child: const Text(
                    'Términos de Privacidad | Política de Uso',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
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

  final List<Widget> _pages = const [
    PlaceholderView(title: 'Shop (Marketplace)'),
    PlaceholderView(title: 'Home / Feed'),
    PlaceholderView(title: 'Carrito'),
    PlaceholderView(title: 'Perfil de Usuario'),
  ];

  void _onAddPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Próximamente: Registrar nuevo activo')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: Text(user?.email ?? 'Vault'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: VaultBottomNavBar(
        currentIndex: _currentIndex,
        onTabSelected: (i) => setState(() => _currentIndex = i),
        onAddPressed: _onAddPressed,
      ),
    );
  }
}