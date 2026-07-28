import 'package:equatable/equatable.dart';

/// Una orden de compra en escrow (ver `payment/src/features/orders/`): el
/// comprador ya pagó, el dinero queda retenido hasta que se confirme la
/// entrega (`POST /orders/:id/confirm`, no conectado todavía -- ver plan).
class OrderEntity extends Equatable {
  final String id;
  final String sellerId;
  final String assetId;
  final int amountCents;
  final int commissionCents;
  final int sellerAmountCents;
  final String currency;
  final String status;

  const OrderEntity({
    required this.id,
    required this.sellerId,
    required this.assetId,
    required this.amountCents,
    required this.commissionCents,
    required this.sellerAmountCents,
    required this.currency,
    required this.status,
  });

  @override
  List<Object?> get props =>
      [id, sellerId, assetId, amountCents, commissionCents, sellerAmountCents, currency, status];
}
