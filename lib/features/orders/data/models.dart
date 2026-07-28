import '../domain/entities.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.sellerId,
    required super.assetId,
    required super.amountCents,
    required super.commissionCents,
    required super.sellerAmountCents,
    required super.currency,
    required super.status,
  });

  /// Decodifica `OrderResponse` de `POST /orders` -- respuesta plana, sin
  /// envoltura (igual que `POST /subscriptions`).
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      sellerId: json['seller_id'] as String,
      assetId: json['asset_id'] as String,
      amountCents: (json['amount_cents'] as num).toInt(),
      commissionCents: (json['commission_cents'] as num?)?.toInt() ?? 0,
      sellerAmountCents: (json['seller_amount_cents'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'mxn',
      status: json['status'] as String? ?? '',
    );
  }
}
