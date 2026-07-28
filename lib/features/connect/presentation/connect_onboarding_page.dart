import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/api_config.dart';
import '../../../core/dimens.dart';
import '../../../core/theme.dart';
import '../../auth/presentation/providers.dart';
import '../domain/usecases.dart';
import 'providers.dart';

/// Pantalla "Cobros": onboarding de Stripe Connect. Sin esto, `payment/`
/// rechaza cualquier compra hacia esta cuenta con "vendedor no configurado"
/// (ver `CreateOrderUseCase.go`) -- es la pieza que faltaba conectar para
/// que el checkout con tarjeta del carrito realmente funcione en la
/// práctica, no solo del lado del comprador.
class ConnectOnboardingPage extends ConsumerStatefulWidget {
  const ConnectOnboardingPage({super.key});

  @override
  ConsumerState<ConnectOnboardingPage> createState() => _ConnectOnboardingPageState();
}

class _ConnectOnboardingPageState extends ConsumerState<ConnectOnboardingPage> {
  bool _opening = false;

  /// Stripe exige refresh_url/return_url válidas, pero no necesitan hacer
  /// nada especial del lado de la app -- el usuario completa el registro
  /// en el navegador y vuelve a la app a mano, luego usa "Actualizar
  /// estado" acá abajo.
  String get _baseUrl => ApiConfig.baseUrl.replaceFirst(RegExp(r'/api/v1/?$'), '');

  Future<void> _startOnboarding() async {
    final email = ref.read(authControllerProvider).user?.email;
    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo identificar tu cuenta')),
      );
      return;
    }

    setState(() => _opening = true);
    final result = await ref.read(createOnboardingLinkUseCaseProvider)(
      CreateOnboardingLinkParams(
        email: email,
        refreshUrl: '$_baseUrl/connect/refresh',
        returnUrl: '$_baseUrl/connect/return',
      ),
    );
    if (!mounted) return;
    setState(() => _opening = false);

    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
      (url) async {
        final uri = Uri.parse(url);
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!launched && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo abrir el link de registro')),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final state = ref.watch(connectStatusControllerProvider);

    return Scaffold(
      backgroundColor: VaultColors.background,
      appBar: AppBar(title: const Text('Cobros')),
      body: SafeArea(
        child: switch (state.status) {
          ConnectStatusLoad.loading => const Center(child: CircularProgressIndicator()),
          ConnectStatusLoad.error => Center(
              child: Padding(
                padding: const EdgeInsets.all(VaultSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.errorMessage ?? 'Error al cargar tu estado de cobros'),
                    const SizedBox(height: VaultSpacing.md),
                    TextButton(
                      onPressed: () => ref.read(connectStatusControllerProvider.notifier).load(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),
          ConnectStatusLoad.loaded => Padding(
              padding: const EdgeInsets.all(VaultSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(VaultSpacing.lg),
                    decoration: BoxDecoration(
                      color: VaultColors.surface,
                      borderRadius: VaultRadius.cardBorder,
                      border: Border.all(
                        color: state.account.chargesEnabled
                            ? VaultColors.success
                            : VaultColors.divider,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          state.account.chargesEnabled
                              ? Icons.check_circle
                              : Icons.info_outline,
                          color: state.account.chargesEnabled
                              ? VaultColors.success
                              : VaultColors.textSecondary,
                        ),
                        const SizedBox(width: VaultSpacing.md),
                        Expanded(
                          child: Text(
                            state.account.chargesEnabled
                                ? 'Listo para recibir pagos'
                                : 'Todavía no puedes recibir pagos: completa tu registro con Stripe.',
                            style: tt.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: VaultSpacing.xl),
                  if (!state.account.chargesEnabled)
                    ElevatedButton.icon(
                      onPressed: _opening ? null : _startOnboarding,
                      icon: _opening
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.open_in_new),
                      label: Text(_opening ? 'Abriendo...' : 'Configurar cobros'),
                    ),
                  const SizedBox(height: VaultSpacing.md),
                  TextButton.icon(
                    onPressed: () => ref.read(connectStatusControllerProvider.notifier).load(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Actualizar estado'),
                  ),
                ],
              ),
            ),
        },
      ),
    );
  }
}
