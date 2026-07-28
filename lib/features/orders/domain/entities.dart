import 'package:equatable/equatable.dart';

/// Los tres estados posibles de una [OrderEntity] -- deben coincidir con
/// `entities.Order` en `payment/src/features/orders/domain/entities/Order.go`.
abstract class OrderStatus {
  static const held = 'retenido';
  static const shipped = 'enviado';
  static const released = 'liberado';
}

/// Una orden de compra en escrow (ver `payment/src/features/orders/`): el
/// comprador ya pagó, el dinero queda retenido hasta que el vendedor la
/// marque como enviada (`POST /orders/:id/ship`) y el comprador confirme
/// la entrega (`POST /orders/:id/confirm`).
class OrderEntity extends Equatable {
  final String id;
  final String sellerId;
  final String assetId;
  final int amountCents;
  final int commissionCents;
  final int sellerAmountCents;
  final String currency;
  final String status;
  final DateTime createdAt;

  const OrderEntity({
    required this.id,
    required this.sellerId,
    required this.assetId,
    required this.amountCents,
    required this.commissionCents,
    required this.sellerAmountCents,
    required this.currency,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        sellerId,
        assetId,
        amountCents,
        commissionCents,
        sellerAmountCents,
        currency,
        status,
        createdAt,
      ];
}
