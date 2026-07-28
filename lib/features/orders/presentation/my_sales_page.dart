import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/dimens.dart';
import '../../../core/theme.dart';
import '../domain/entities.dart';
import 'providers.dart';

/// Pantalla "Mis ventas" (vendedor): la parte de logística que faltaba --
/// antes de esto el vendedor no se enteraba de una venta nueva ni tenía
/// forma de marcarla como enviada (`POST /orders/:id/ship`, nuevo endpoint).
class MySalesPage extends ConsumerWidget {
  const MySalesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mySalesControllerProvider);

    return Scaffold(
      backgroundColor: VaultColors.background,
      appBar: AppBar(title: const Text('Mis ventas')),
      body: switch (state.status) {
        MySalesStatus.loading => const Center(child: CircularProgressIndicator()),
        MySalesStatus.error => Center(
            child: Padding(
              padding: const EdgeInsets.all(VaultSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.errorMessage ?? 'Error al cargar tus ventas'),
                  const SizedBox(height: VaultSpacing.md),
                  TextButton(
                    onPressed: () => ref.read(mySalesControllerProvider.notifier).load(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
        MySalesStatus.loaded => state.orders.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(VaultSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.local_shipping_outlined,
                          size: 56, color: VaultColors.textSecondary),
                      const SizedBox(height: VaultSpacing.md),
                      const Text(
                        'Todavía no tienes ventas',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: VaultSpacing.xs),
                      Text(
                        'Cuando alguien te compre un producto, aparecerá aquí.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: VaultColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(VaultSpacing.md),
                itemCount: state.orders.length,
                separatorBuilder: (_, _) => const SizedBox(height: VaultSpacing.sm),
                itemBuilder: (context, index) {
                  final order = state.orders[index];
                  return _SaleTile(
                    order: order,
                    onShip: order.status == OrderStatus.held
                        ? () async {
                            final ok =
                                await ref.read(mySalesControllerProvider.notifier).ship(order.id);
                            if (!context.mounted) return;
                            if (!ok) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    ref.read(mySalesControllerProvider).errorMessage ??
                                        'No se pudo marcar el pedido como enviado',
                                  ),
                                ),
                              );
                            }
                          }
                        : null,
                  );
                },
              ),
      },
    );
  }
}

class _SaleTile extends StatelessWidget {
  final OrderEntity order;
  final VoidCallback? onShip;

  const _SaleTile({required this.order, required this.onShip});

  (String, Color) get _statusInfo => switch (order.status) {
        OrderStatus.held => ('Retenido · por enviar', VaultColors.textSecondary),
        OrderStatus.shipped => ('Enviado · esperando confirmación', VaultColors.accent),
        OrderStatus.released => ('Pagado', VaultColors.success),
        _ => (order.status, VaultColors.textSecondary),
      };

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final (statusLabel, statusColor) = _statusInfo;
    final sellerAmount = order.sellerAmountCents / 100;

    return Container(
      padding: const EdgeInsets.all(VaultSpacing.md),
      decoration: BoxDecoration(
        color: VaultColors.surface,
        borderRadius: VaultRadius.cardBorder,
        border: Border.all(color: VaultColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Venta #${order.id.substring(0, 8)}', style: tt.titleSmall),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: VaultSpacing.sm, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(VaultRadius.sm),
                ),
                child: Text(
                  statusLabel,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: VaultSpacing.xs),
          Text(
            'Recibes \$${sellerAmount.toStringAsFixed(0)} ${order.currency.toUpperCase()}',
            style: tt.bodyMedium,
          ),
          if (onShip != null) ...[
            const SizedBox(height: VaultSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onShip,
                child: const Text('Marcar como enviado'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
