import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';
import 'widgets.dart';

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

class _WelcomePage extends StatelessWidget {
  final VoidCallback onLoginWithEmail;
  const _WelcomePage({required this.onLoginWithEmail});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fondo
        Positioned.fill(
          child: Image.asset('assets/images/fondologin.png', fit: BoxFit.cover),
        ),
        // Overlay semitransparente
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
                // Botón Google
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
                // Botón Correo
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
                const SizedBox(height: 24),
                const Text('Términos de Privacidad | Política de Uso',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
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
              children: const [
                SizedBox(height: 16),
                Text('VAULT',
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2),
                    textAlign: TextAlign.center),
                SizedBox(height: 8),
                Text('¡Bienvenido otra vez!',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
                SizedBox(height: 4),
                Text('Tu colección premium, bajo control inteligente.',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                    textAlign: TextAlign.center),
                SizedBox(height: 40),
                LoginForm(),
                SizedBox(height: 24),
                Text('Términos de Privacidad | Política de Uso',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vault'),
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
      body: Center(
        child: Text(
          '¡Bienvenido, ${user?.email ?? ''}!',
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}