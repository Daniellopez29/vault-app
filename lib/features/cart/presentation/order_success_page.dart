import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/dimens.dart';
import '../../../core/router.dart';
import '../../../core/theme.dart';
import '../domain/entities.dart';
import 'providers.dart';
import 'widgets.dart';

class OrderSuccessPage extends ConsumerStatefulWidget {
  const OrderSuccessPage({super.key});

  @override
  ConsumerState<OrderSuccessPage> createState() => _OrderSuccessPageState();
}

class _OrderSuccessPageState extends ConsumerState<OrderSuccessPage> {
  late final OrderSummaryEntity _summary;

  @override
  void initState() {
    super.initState();
    // Congela el resumen ANTES de vaciar el carrito, para mostrarlo en pantalla.
    _summary = ref.read(cartControllerProvider).summary;
    // La compra se completó: se vacía el carrito.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cartControllerProvider.notifier).clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: VaultColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(VaultSpacing.lg),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  color: VaultColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: VaultIconSize.xl,
                ),
              ),
              const SizedBox(height: VaultSpacing.lg),
              Text(
                'Orden creada exitosamente',
                style: tt.headlineMedium?.copyWith(color: VaultColors.success),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: VaultSpacing.sm),
              Text(
                'Aquí tienes un resumen de tu pedido',
                style: tt.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: VaultSpacing.xl),
              Container(
                padding: const EdgeInsets.all(VaultSpacing.lg),
                decoration: BoxDecoration(
                  color: VaultColors.surface,
                  borderRadius: VaultRadius.cardBorder,
                  border: Border.all(color: VaultColors.divider),
                ),
                child: Column(
                  children: [
                    SummaryRow(
                      label: 'Subtotal',
                      value: '\$${_summary.subtotal.toStringAsFixed(0)}',
                    ),
                    if (_summary.discount > 0)
                      SummaryRow(
                        label: 'Descuento',
                        value: '-\$${_summary.discount.toStringAsFixed(0)}',
                      ),
                    Divider(color: VaultColors.divider),
                    SummaryRow(
                      label: 'Total',
                      value: '\$${_summary.total.toStringAsFixed(0)}',
                      emphasized: true,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.go(AppRoutes.home),
                  icon: const Icon(Icons.home_outlined),
                  label: const Text('Regresar al home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}