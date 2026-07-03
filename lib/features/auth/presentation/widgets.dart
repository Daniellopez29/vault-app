import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/theme.dart';
import 'providers.dart';
import 'pages.dart';
import 'role_selection_page.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _isLogin = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (_isLogin) {
      ref.read(authControllerProvider.notifier).login(
        email: email,
        password: password,
      );
    } else {
      ref.read(authControllerProvider.notifier).register(
        email: email,
        password: password,
        fullName: _nameController.text.trim(),
      );
    }
  }

  InputDecoration _fieldDecoration({
    required String label,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: VaultColors.primary,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(prefixIcon, color: VaultColors.primary),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withOpacity(0.85),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: VaultColors.primary.withOpacity(0.2),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: VaultColors.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: VaultColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: VaultColors.error, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final isLoading = state.status == AuthStatus.loading;

    ref.listen(authControllerProvider, (_, next) {
      if (next.status == AuthStatus.authenticated) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else if (next.status == AuthStatus.roleSelection) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const RoleSelectionPage()),
        );
      }
    });

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!_isLogin) ...[
            TextFormField(
              controller: _nameController,
              decoration: _fieldDecoration(
                label: 'Nombre completo',
                prefixIcon: Icons.person_outline,
              ),
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(color: VaultColors.primary),
              validator: (v) =>
              v == null || v.trim().isEmpty ? 'Ingresa tu nombre' : null,
            ),
            const SizedBox(height: 16),
          ],
          TextFormField(
            controller: _emailController,
            decoration: _fieldDecoration(
              label: 'Correo electrónico',
              prefixIcon: Icons.email_outlined,
            ),
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: VaultColors.primary),
            validator: (v) =>
            v == null || !v.contains('@') ? 'Correo inválido' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscure,
            decoration: _fieldDecoration(
              label: 'Contraseña',
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                  color: VaultColors.primary,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            style: const TextStyle(color: VaultColors.primary),
            validator: (v) =>
            v == null || v.length < 6 ? 'Mínimo 6 caracteres' : null,
          ),
          if (state.status == AuthStatus.error) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: VaultColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                state.errorMessage ?? '',
                style: const TextStyle(
                  color: VaultColors.error,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: isLoading ? null : _submit,
            child: isLoading
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : Text(_isLogin ? 'Iniciar sesión' : 'Crear cuenta'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => setState(() {
              _isLogin = !_isLogin;
              _nameController.clear();
            }),
            child: Text(
              _isLogin
                  ? '¿No tienes cuenta? Regístrate'
                  : '¿Ya tienes cuenta? Inicia sesión',
              style: const TextStyle(
                color: VaultColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Row(children: [
            const Expanded(child: Divider(color: VaultColors.primary)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'o',
                style: TextStyle(
                  color: VaultColors.primary.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Expanded(child: Divider(color: VaultColors.primary)),
          ]),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: isLoading
                ? null
                : () =>
                ref.read(authControllerProvider.notifier).loginWithGoogle(),
            icon: const FaIcon(
              FontAwesomeIcons.google,
              size: 18,
              color: VaultColors.primary,
            ),
            label: const Text(
              'Continuar con Google',
              style: TextStyle(color: VaultColors.primary),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.85),
              side: const BorderSide(color: VaultColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}