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
    required super.createdAt,
  });

  /// Decodifica `OrderResponse` de `POST /orders`, `GET /orders/mine` y
  /// `GET /orders/selling` -- misma forma plana en los tres casos (ver
  /// `OrderResponse.go`).
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
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
