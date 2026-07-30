import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/dashed_border.dart';
import '../../../../core/enums.dart';
import '../../../../core/screen_security.dart';
import '../../../../core/theme.dart';
import '../../../core/validation.dart';
import 'providers.dart';

class RegisterFormPage extends ConsumerStatefulWidget {
  final UserRole role;

  /// A dónde ir tras registrarse con éxito -- lo decide la opción elegida
  /// en RoleSelectionPage (Home / registrar activo / registrar negocio).
  final String destination;

  const RegisterFormPage({super.key, required this.role, required this.destination});

  @override
  ConsumerState<RegisterFormPage> createState() => _RegisterFormPageState();
}

class _RegisterFormPageState extends ConsumerState<RegisterFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscure = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    ScreenSecurity.enable();
  }

  @override
  void dispose() {
    ScreenSecurity.disable();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onAvatarTap() {
    // Solo visual por ahora. La foto de perfil real se sube desde el
    // Perfil una vez creada la cuenta (ProfileHeader ya lo soporta).
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Puedes agregar tu foto de perfil después, desde Perfil')),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    ref.read(authControllerProvider.notifier).register(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      fullName: _nameController.text.trim(),
      role: widget.role,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final state = ref.watch(authControllerProvider);
    final isLoading = state.status == AuthStatus.loading;

    ref.listen(authControllerProvider, (_, next) {
      if (next.status == AuthStatus.authenticated) {
        context.go(widget.destination);
      }
    });

    return Scaffold(
      backgroundColor: VaultColors.background,
      appBar: AppBar(
        title: const Text('Crear cuenta'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Registro como ${widget.role.displayName}',
                  style: tt.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.role.description,
                  style: tt.bodyMedium,
                ),
                const SizedBox(height: 24),

                // Avatar de foto de perfil (solo visual por ahora).
                Center(
                  child: _ProfileAvatarPicker(onTap: _onAvatarTap),
                ),
                const SizedBox(height: 24),

                _Field(
                  controller: _nameController,
                  label: 'Nombre completo',
                  icon: Icons.person_outline,
                  textCapitalization: TextCapitalization.words,
                  validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Ingresa tu nombre' : null,
                ),
                const SizedBox(height: 16),
                _Field(
                  controller: _emailController,
                  label: 'Correo electrónico',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                  v == null || !isValidEmail(v) ? 'Correo inválido' : null,
                ),
                const SizedBox(height: 16),
                _Field(
                  controller: _passwordController,
                  label: 'Contraseña',
                  icon: Icons.lock_outline,
                  obscureText: _obscure,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                      color: VaultColors.primary,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  validator: (v) =>
                  v == null || v.length < 6 ? 'Mínimo 6 caracteres' : null,
                ),
                const SizedBox(height: 16),
                _Field(
                  controller: _confirmPasswordController,
                  label: 'Confirmar contraseña',
                  icon: Icons.lock_outline,
                  obscureText: _obscureConfirm,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                      color: VaultColors.primary,
                    ),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  validator: (v) =>
                  v != _passwordController.text ? 'Las contraseñas no coinciden' : null,
                ),

                if (state.status == AuthStatus.error) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: VaultColors.error.withValues(alpha: 0.1),
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

                const SizedBox(height: 28),
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
                      : const Text('Crear cuenta'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Avatar circular para la foto de perfil. Solo visual por ahora:
/// al tocarlo avisa que se agrega después desde el Perfil.
class _ProfileAvatarPicker extends StatelessWidget {
  final VoidCallback onTap;

  const _ProfileAvatarPicker({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            children: [
              DashedBorder(
                color: VaultColors.divider,
                shape: BoxShape.circle,
                strokeWidth: 2,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: VaultColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_outline,
                    size: 44,
                    color: VaultColors.textSecondary,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: VaultColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: VaultColors.background, width: 2),
                  ),
                  child: const Icon(
                    Icons.photo_camera_outlined,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Agregar foto de perfil',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

/// Campo de texto reutilizable, con el estilo del theme.
class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      style: const TextStyle(color: VaultColors.primary),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: VaultColors.primary),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: VaultColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: VaultColors.primary.withValues(alpha: 0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: VaultColors.primary, width: 2),
        ),
      ),
      validator: validator,
    );
  }
}
