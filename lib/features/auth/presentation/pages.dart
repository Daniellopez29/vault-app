import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router.dart';
import '../../../../core/theme.dart';
import '../../../core/screen_security.dart';
import '../../../core/widgets/animated_logo.dart';
import 'widgets.dart';

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
                  const VaultAnimatedLogo(height: 140),
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