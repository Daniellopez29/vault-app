import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:go_router/go_router.dart';
import '../../../core/dimens.dart';
import '../../../core/router.dart';
import '../../../core/theme.dart';
<<<<<<< HEAD
import '../../../core/widgets/fill_button.dart';
=======
import '../../../core/widgets/vault_card_field.dart';
>>>>>>> 45ae271c3e622d33c887d33c5a7e7a10cd5a7e95
import '../../auth/presentation/providers.dart';
import '../../orders/domain/usecases.dart';
import '../../orders/presentation/providers.dart';
import '../domain/entities.dart';
import 'providers.dart';
import 'widgets.dart';

/// Ícono representativo de cada tipo de pago. Único lugar que lo decide.
IconData _iconFor(PaymentType type) {
  switch (type) {
    case PaymentType.card:     return Icons.credit_card;
    case PaymentType.transfer: return Icons.account_balance;
    case PaymentType.cash:     return Icons.payments_outlined;
  }
}

class PaymentMethodPage extends ConsumerStatefulWidget {
  const PaymentMethodPage({super.key});

  @override
  ConsumerState<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends ConsumerState<PaymentMethodPage> {
  String? _selectedId;
  PaymentType? _selectedType;
  bool _paying = false;
  bool _cardComplete = false;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final summary = ref.watch(cartControllerProvider).summary;
    final methodsAsync = ref.watch(paymentMethodsProvider);
    final isCardSelected = _selectedType == PaymentType.card;

    final canPay = _selectedType != null &&
        !_paying &&
        !(isCardSelected && !_cardComplete);

    return Scaffold(
      backgroundColor: VaultColors.background,
      appBar: AppBar(
        title: const Text('Método de pago'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(VaultSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: VaultSpacing.sm),
              SummaryRow(label: 'Subtotal', value: '\$${summary.subtotal.toStringAsFixed(0)}'),
              if (summary.discount > 0)
                SummaryRow(label: 'Descuento', value: '-\$${summary.discount.toStringAsFixed(0)}'),
              const Divider(color: VaultColors.divider),
              SummaryRow(
                label: 'Total',
                value: '\$${summary.total.toStringAsFixed(0)}',
                emphasized: true,
              ),
              const SizedBox(height: VaultSpacing.lg),
              Expanded(
                child: SingleChildScrollView(
                  child: methodsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, _) => Center(
                      child: Text(
                        'Error al cargar los métodos de pago',
                        style: tt.bodyMedium,
                      ),
                    ),
                    data: (methods) {
                      if (_selectedId == null && methods.isNotEmpty) {
                        _selectedId = methods.first.id;
                        _selectedType = methods.first.type;
                      }
                      return Column(
                        children: [
                          for (final method in methods) ...[
                            _PaymentTile(
                              method: method,
                              selected: method.id == _selectedId,
                              onTap: () => setState(() {
                                _selectedId = method.id;
                                _selectedType = method.type;
                              }),
                            ),
                            // El campo de tarjeta aparece pegado a "Tarjeta"
                            // en cuanto se elige, no después de TODOS los
                            // métodos -- antes quedaba hasta el final de la
                            // lista, tapado por el teclado al escribir.
                            if (method.type == PaymentType.card &&
                                method.id == _selectedId) ...[
                              const SizedBox(height: VaultSpacing.sm),
                              VaultCardField(
                                onCompleteChanged: (complete) =>
                                    setState(() => _cardComplete = complete),
                              ),
                            ],
                            const SizedBox(height: VaultSpacing.md),
                          ],
<<<<<<< HEAD
                          if (isCardSelected)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: VaultSpacing.md),
                              decoration: BoxDecoration(
                                color: VaultColors.surface,
                                borderRadius: VaultRadius.cardBorder,
                                border: Border.all(color: VaultColors.divider),
                              ),
                              child: stripe.CardField(
                                enablePostalCode: true,
                                onCardChanged: (details) {
                                  setState(() =>
                                      _cardComplete = details?.complete ?? false);
                                },
                              ),
                            ),
=======
>>>>>>> 45ae271c3e622d33c887d33c5a7e7a10cd5a7e95
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: VaultSpacing.md),
              FillButton(
                label: 'Pagar ahora',
                fillingLabel: 'Procesando pago...',
                icon: Icons.lock_outline,
                filling: _paying,
                enabled: canPay,
                onPressed: () => _onPay(_selectedType!),
                onCompleted: _onFillCompleted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Cuando la animación de relleno termina, navegamos al resultado.
  /// Para tarjeta el pago real ya se procesó antes de activar [_paying].
  /// Para transferencia/efectivo solo mostramos instrucciones.
  void _onFillCompleted() {
    // No-op: la navegación ya se hizo en _onPay para no-card,
    // y en _payWithCard para card al terminar el cobro.
  }

  Future<void> _onPay(PaymentType type) async {
    if (type != PaymentType.card) {
      setState(() => _paying = true);
      // Espera a que la animación de relleno avance un poco antes de navegar
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;
      setState(() => _paying = false);
      context.push(AppRoutes.paymentInstructions, extra: type);
      return;
    }
    await _payWithCard();
  }

  Future<void> _payWithCard() async {
    final items = ref.read(cartControllerProvider).items;
    if (items.isEmpty) return;

    final email = ref.read(authControllerProvider).user?.email;
    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('No se pudo identificar tu cuenta para procesar el pago')),
      );
      return;
    }

    setState(() => _paying = true);

    final stripe.PaymentMethod paymentMethod;
    try {
      paymentMethod = await stripe.Stripe.instance.createPaymentMethod(
        params: const stripe.PaymentMethodParams.card(
          paymentMethodData: stripe.PaymentMethodData(),
        ),
      );
    } on stripe.StripeError catch (e) {
      if (!mounted) return;
      setState(() => _paying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('No se pudo procesar la tarjeta: ${e.message}')),
      );
      return;
    } catch (e) {
      if (!mounted) return;
      setState(() => _paying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error inesperado al leer la tarjeta: $e')),
      );
      return;
    }

    final createOrder = ref.read(createOrderUseCaseProvider);
    final failures = <String>[];
    final succeededIds = <String>[];

    for (final item in items) {
      final amountCents = (item.lineTotal * 100).round();
      final result = await createOrder(CreateOrderParams(
        sellerId: item.sellerId,
        assetId: item.id,
        amountCents: amountCents,
        buyerEmail: email,
        paymentMethodId: paymentMethod.id,
      ));
      result.fold(
        (failure) => failures.add('${item.title}: ${failure.message}'),
        (_) => succeededIds.add(item.id),
      );
    }

    if (!mounted) return;
    setState(() => _paying = false);

    if (failures.isEmpty) {
      context.push(AppRoutes.orderSuccess);
      return;
    }

    for (final id in succeededIds) {
      await ref.read(cartControllerProvider.notifier).removeItem(id);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          succeededIds.isEmpty
              ? 'No se pudo procesar el pago: ${failures.join('; ')}'
              : 'Algunos artículos no se pudieron cobrar: ${failures.join('; ')}',
        ),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final PaymentMethodEntity method;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentTile({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: VaultSpacing.lg,
          vertical: VaultSpacing.md,
        ),
        decoration: BoxDecoration(
          color: VaultColors.surface,
          borderRadius: VaultRadius.cardBorder,
          border: Border.all(
            color: selected ? VaultColors.accent : VaultColors.divider,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(_iconFor(method.type), color: VaultColors.primary),
            const SizedBox(width: VaultSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(method.label, style: tt.titleMedium),
                  if (method.description.isNotEmpty)
                    Text(
                      method.description,
                      style: tt.labelSmall?.copyWith(
                        color: VaultColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? VaultColors.accent : VaultColors.textSecondary,
              size: VaultIconSize.md,
            ),
          ],
        ),
      ),
    );
  }
}