import 'package:equatable/equatable.dart';

/// Un artículo dentro del carrito: el activo + la cantidad.
class CartItemEntity extends Equatable {
  final String id;
  final String sellerId;
  final String title;
  final String brand;
  final String imageUrl;
  final double unitPrice;
  final int quantity;

  const CartItemEntity({
    required this.id,
    required this.sellerId,
    required this.title,
    required this.brand,
    required this.imageUrl,
    required this.unitPrice,
    this.quantity = 1,
  });

  double get lineTotal => unitPrice * quantity;

  CartItemEntity copyWith({int? quantity}) => CartItemEntity(
    id: id,
    sellerId: sellerId,
    title: title,
    brand: brand,
    imageUrl: imageUrl,
    unitPrice: unitPrice,
    quantity: quantity ?? this.quantity,
  );

  @override
  List<Object?> get props => [id, sellerId, title, brand, imageUrl, unitPrice, quantity];
}

/// Tipo de método de pago. El ícono y el nombre derivan de aquí,
/// sin hardcodeo disperso por los widgets.
enum PaymentType { card, transfer, cash }

class PaymentMethodEntity extends Equatable {
  final String id;
  final PaymentType type;
  final String label;
  final String description;

  const PaymentMethodEntity({
    required this.id,
    required this.type,
    required this.label,
    this.description = '',
  });

  @override
  List<Object?> get props => [id, type, label, description];
}

/// Resumen de costos de la orden. La tarifa de uso se calcula con una tasa
/// centralizada, no con un número mágico en la UI.
class OrderSummaryEntity extends Equatable {
  /// Tarifa de uso de la plataforma (10%).
  static const usageFeeRate = 0.10;

  final double subtotal;
  final double fee;
  final double discount;

  const OrderSummaryEntity({
    required this.subtotal,
    required this.fee,
    this.discount = 0,
  });

  double get total => subtotal + fee - discount;

  factory OrderSummaryEntity.fromItems(List<CartItemEntity> items) {
    final subtotal = items.fold<double>(0, (sum, item) => sum + item.lineTotal);
    return OrderSummaryEntity(
      subtotal: subtotal,
      fee: subtotal * usageFeeRate,
    );
  }

  @override
  List<Object?> get props => [subtotal, fee, discount];
}