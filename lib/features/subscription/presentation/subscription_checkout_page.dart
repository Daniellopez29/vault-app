import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:go_router/go_router.dart';
import '../../../core/dimens.dart';
import '../../../core/router.dart';
import '../../../core/theme.dart';
import '../../auth/presentation/providers.dart';
import '../domain/entities.dart';
import 'providers.dart';

/// Checkout real de una suscripción: captura la tarjeta con el CardField de
/// Stripe y manda el PaymentMethod resultante a `POST /subscriptions` junto
/// con el plan elegido. No reutiliza el `PaymentMethodPage` del carrito
/// porque ese es puro mock (no llama a Stripe ni al backend).
class SubscriptionCheckoutPage extends ConsumerStatefulWidget {
  final SubscriptionPlan plan;

  const SubscriptionCheckoutPage({super.key, required this.plan});

  @override
  ConsumerState<SubscriptionCheckoutPage> createState() =>
      _SubscriptionCheckoutPageState();
}

class _SubscriptionCheckoutPageState
    extends ConsumerState<SubscriptionCheckoutPage> {
  bool _cardComplete = false;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final email = ref.watch(authControllerProvider).user?.email;

    if (email == null) {
      return const Scaffold(
        body: Center(child: Text('Sesión no válida.')),
      );
    }

    final params = (planId: widget.plan.id, email: email);
    final state = ref.watch(subscriptionCheckoutControllerProvider(params));
    final controller =
        ref.read(subscriptionCheckoutControllerProvider(params).notifier);

    ref.listen(subscriptionCheckoutControllerProvider(params), (previous, next) {
      if (next.status == CheckoutStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
      if (next.status == CheckoutStatus.success) {
        // Sin esto, "Mi suscripción" y el flujo de "Anunciar" seguían
        // viendo el estado de antes de pagar (subscriptionStatusControllerProvider
        // solo se cargaba una vez, nunca se refrescaba solo).
        ref.invalidate(subscriptionStatusControllerProvider);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text('¡Suscripción activada!'),
            content: Text('Ya contrataste el plan ${widget.plan.name}.'),
            actions: [
              TextButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Ir al inicio'),
              ),
            ],
          ),
        );
      }
    });

    final submitting = state.status == CheckoutStatus.submitting;

    return Scaffold(
      backgroundColor: VaultColors.background,
      appBar: AppBar(
        title: const Text('Pago'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(VaultSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: VaultSpacing.md),
              Text(
                widget.plan.name,
                style: tt.titleLarge,
                textAlign: TextAlign.center,
              ),
              Text(
                '\$${widget.plan.price.toStringAsFixed(0)} / mes',
                style: tt.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: VaultSpacing.xl),
              Text('Datos de tu tarjeta', style: tt.titleMedium),
              const SizedBox(height: VaultSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: VaultSpacing.md),
                decoration: BoxDecoration(
                  color: VaultColors.surface,
                  borderRadius: VaultRadius.cardBorder,
                  border: Border.all(color: VaultColors.divider),
                ),
                child: stripe.CardField(
                  enablePostalCode: true,
                  onCardChanged: (details) {
                    setState(() => _cardComplete = details?.complete ?? false);
                  },
                ),
              ),
              const SizedBox(height: VaultSpacing.sm),
              Text(
                'Tu tarjeta se procesa directamente con Stripe; no la guardamos '
                'en nuestros servidores.',
                style: tt.bodyMedium,
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: (!_cardComplete || submitting) ? null : controller.pay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: VaultColors.accent,
                  foregroundColor: Colors.white,
                ),
                icon: submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.lock_outline),
                label: Text(submitting ? 'Procesando...' : 'Pagar ahora'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
