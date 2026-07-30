import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/dimens.dart';
import '../../../core/theme.dart';
import '../../reviews/presentation/write_review_dialog.dart';
import '../domain/entities.dart';
import 'providers.dart';

/// Pantalla "Mis pedidos" (comprador): antes de esto, después de pagar en
/// el carrito no había dónde ver el pedido ni confirmar que llegó --
/// `POST /orders/:id/confirm` ya existía en el backend sin ninguna
/// pantalla que lo llamara.
class MyOrdersPage extends ConsumerWidget {
  const MyOrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myOrdersControllerProvider);

    return Scaffold(
      backgroundColor: VaultColors.background,
      appBar: AppBar(title: const Text('Mis pedidos')),
      body: switch (state.status) {
        MyOrdersStatus.loading => const Center(child: CircularProgressIndicator()),
        MyOrdersStatus.error => Center(
            child: Padding(
              padding: const EdgeInsets.all(VaultSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.errorMessage ?? 'Error al cargar tus pedidos'),
                  const SizedBox(height: VaultSpacing.md),
                  TextButton(
                    onPressed: () => ref.read(myOrdersControllerProvider.notifier).load(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
        MyOrdersStatus.loaded => state.orders.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(VaultSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.receipt_long_outlined,
                          size: 56, color: VaultColors.textSecondary),
                      const SizedBox(height: VaultSpacing.md),
                      const Text(
                        'Todavía no tienes pedidos',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: VaultSpacing.xs),
                      Text(
                        'Cuando compres un producto con tarjeta, aparecerá aquí.',
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
                  return _OrderTile(
                    order: order,
                    onReview: order.status == OrderStatus.released
                        ? () async {
                            final published = await showDialog<bool>(
                              context: context,
                              builder: (_) => WriteReviewDialog(providerId: order.sellerId),
                            );
                            if (published == true && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Reseña publicada')),
                              );
                            }
                          }
                        : null,
                    onConfirm: order.status == OrderStatus.shipped
                        ? () async {
                            final ok = await ref
                                .read(myOrdersControllerProvider.notifier)
                                .confirm(order.id);
                            if (!context.mounted) return;
                            if (!ok) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    ref.read(myOrdersControllerProvider).errorMessage ??
                                        'No se pudo confirmar el pedido',
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

class _OrderTile extends StatelessWidget {
  final OrderEntity order;
  final VoidCallback? onConfirm;
  final VoidCallback? onReview;

  const _OrderTile({required this.order, required this.onConfirm, required this.onReview});

  /// Copy + color de cada estado -- mismo criterio visual que `_AdTile`
  /// (activo/inactivo) en `my_ads_page.dart`.
  (String, Color) get _statusInfo => switch (order.status) {
        OrderStatus.held => ('Retenido · esperando envío', VaultColors.textSecondary),
        OrderStatus.shipped => ('Enviado', VaultColors.accent),
        OrderStatus.released => ('Confirmado', VaultColors.success),
        _ => (order.status, VaultColors.textSecondary),
      };

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final (statusLabel, statusColor) = _statusInfo;
    final total = order.amountCents / 100;

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
                child: Text('Pedido #${order.id.substring(0, 8)}', style: tt.titleSmall),
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
            '\$${total.toStringAsFixed(0)} ${order.currency.toUpperCase()}',
            style: tt.bodyMedium,
          ),
          if (order.status == OrderStatus.held) ...[
            const SizedBox(height: VaultSpacing.sm),
            Text(
              'Esperando que el vendedor envíe tu pedido.',
              style: tt.bodySmall?.copyWith(color: VaultColors.textSecondary),
            ),
          ],
          if (onConfirm != null) ...[
            const SizedBox(height: VaultSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onConfirm,
                child: const Text('Confirmar recepción'),
              ),
            ),
          ],
          if (onReview != null) ...[
            const SizedBox(height: VaultSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onReview,
                child: const Text('Dejar reseña'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
