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

/// Resumen de costos de la orden. El comprador paga exactamente el precio
/// listado -- antes había acá una "tarifa de uso" fija del 10% cobrada al
/// comprador, sin relación con la comisión real de Vault (que ya varía
/// según el plan del vendedor, ver SellerCommissionAdapter.go en payment/):
/// esa comisión se sigue descontando del pago al vendedor al liberar el
/// escrow, nunca del lado del comprador -- es el modelo estándar de
/// marketplace, y así el beneficio de un plan mejor sí se refleja en
/// cuánto le llega al vendedor, en vez de ser invisible.
class OrderSummaryEntity extends Equatable {
  final double subtotal;
  final double discount;

  const OrderSummaryEntity({
    required this.subtotal,
    this.discount = 0,
  });

  double get total => subtotal - discount;

  factory OrderSummaryEntity.fromItems(List<CartItemEntity> items) {
    final subtotal = items.fold<double>(0, (sum, item) => sum + item.lineTotal);
    return OrderSummaryEntity(subtotal: subtotal);
  }

  @override
  List<Object?> get props => [subtotal, discount];
}