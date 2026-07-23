import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/dimens.dart';
import '../../../core/router.dart';
import '../../../core/theme.dart';
import '../domain/entities.dart';
import 'providers.dart';

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

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final total = ref.watch(cartControllerProvider).summary.total;
    final methodsAsync = ref.watch(paymentMethodsProvider);

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
              const SizedBox(height: VaultSpacing.md),
              Text('TOTAL', style: tt.bodyMedium, textAlign: TextAlign.center),
              Text(
                '\$${total.toStringAsFixed(0)}',
                style: tt.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: VaultSpacing.xl),
              Expanded(
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
                    return ListView.separated(
                      itemCount: methods.length,
                      separatorBuilder: (_, _) =>
                      const SizedBox(height: VaultSpacing.md),
                      itemBuilder: (context, index) {
                        final method = methods[index];
                        return _PaymentTile(
                          method: method,
                          selected: method.id == _selectedId,
                          onTap: () => setState(() {
                            _selectedId = method.id;
                            _selectedType = method.type;
                          }),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: VaultSpacing.md),
              ElevatedButton.icon(
                onPressed: _selectedType == null
                    ? null
                    : () => _onPay(_selectedType!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: VaultColors.accent,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.lock_outline),
                label: const Text('Pagar ahora'),
              ),
              const SizedBox(height: VaultSpacing.sm),
              TextButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Añadir método (próximamente)')),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: VaultColors.accent,
                ),
                icon: const Icon(Icons.add),
                label: const Text('Añadir nuevo'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Segun el metodo elegido: la tarjeta ira por Stripe (pendiente), y
  /// transferencia y efectivo muestran sus instrucciones de pago.
  void _onPay(PaymentType type) {
    if (type == PaymentType.card) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El pago con tarjeta se procesa con Stripe'),
        ),
      );
      return;
    }
    context.push(AppRoutes.paymentInstructions, extra: type);
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
