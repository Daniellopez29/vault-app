import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:go_router/go_router.dart';
import '../../../core/dimens.dart';
import '../../../core/router.dart';
import '../../../core/theme.dart';
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
              // El comprador paga exactamente el precio listado -- la
              // comisión de Vault (variable según el plan del vendedor) se
              // descuenta del pago al vendedor al liberar el escrow, no de
              // acá. Ver OrderSummaryEntity.
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
                      // Preselecciona el primero si aún no hay selección.
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
                            const SizedBox(height: VaultSpacing.md),
                          ],
                          if (isCardSelected)
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
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: VaultSpacing.md),
              ElevatedButton.icon(
                onPressed: (_selectedType == null ||
                        _paying ||
                        (isCardSelected && !_cardComplete))
                    ? null
                    : () => _onPay(_selectedType!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: VaultColors.accent,
                  foregroundColor: Colors.white,
                ),
                icon: _paying
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.lock_outline),
                label: Text(_paying ? 'Procesando...' : 'Pagar ahora'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Segun el metodo elegido: la tarjeta cobra de una vez con Stripe, y
  /// transferencia y efectivo muestran sus instrucciones de pago.
  Future<void> _onPay(PaymentType type) async {
    if (type != PaymentType.card) {
      context.push(AppRoutes.paymentInstructions, extra: type);
      return;
    }
    await _payWithCard();
  }

  /// El carrito puede tener artículos de distintos vendedores -- cada uno
  /// implica un cargo/escrow independiente (`POST /orders` por artículo,
  /// ver `CreateOrderUseCase.go`). Si alguno falla a media, NO se reintenta
  /// todo desde cero: solo se quitan del carrito los que sí se cobraron,
  /// para que un segundo intento no vuelva a cobrar lo mismo dos veces.
  Future<void> _payWithCard() async {
    final items = ref.read(cartControllerProvider).items;
    if (items.isEmpty) return;

    final email = ref.read(authControllerProvider).user?.email;
    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo identificar tu cuenta para procesar el pago')),
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
        SnackBar(content: Text('No se pudo procesar la tarjeta: ${e.message}')),
      );
      return;
    } catch (e) {
      if (!mounted) return;
      setState(() => _paying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error inesperado al leer la tarjeta: $e')),
      );
      return;
    }

    final createOrder = ref.read(createOrderUseCaseProvider);
    final failures = <String>[];
    final succeededIds = <String>[];

    for (final item in items) {
      // El comprador paga exactamente el precio listado -- la comisión de
      // Vault se descuenta del lado del vendedor al liberar el escrow (ver
      // CreateOrderUseCase.go / SellerCommissionAdapter.go en payment/), no
      // se le agrega nada al comprador acá.
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
      // Éxito total: OrderSuccessPage lee el resumen del carrito (todavía
      // completo) y lo vacía ella misma -- no se toca acá.
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
