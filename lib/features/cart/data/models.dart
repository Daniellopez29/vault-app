import '../domain/entities.dart';

class CartItemModel extends CartItemEntity {
  const CartItemModel({
    required super.id,
    required super.title,
    required super.brand,
    required super.imageUrl,
    required super.unitPrice,
    super.quantity = 1,
  });

  factory CartItemModel.fromEntity(CartItemEntity e) => CartItemModel(
    id: e.id,
    title: e.title,
    brand: e.brand,
    imageUrl: e.imageUrl,
    unitPrice: e.unitPrice,
    quantity: e.quantity,
  );

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
    id: json['id'] as String,
    title: json['title'] as String,
    brand: json['brand'] as String,
    imageUrl: json['imageUrl'] as String,
    unitPrice: (json['unitPrice'] as num).toDouble(),
    quantity: json['quantity'] as int? ?? 1,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'brand': brand,
    'imageUrl': imageUrl,
    'unitPrice': unitPrice,
    'quantity': quantity,
  };

  /// copyWith a nivel de modelo, para que el datasource devuelva siempre
  /// CartItemModel (y no la entidad base) al modificar cantidades.
  CartItemModel copyModelWith({int? quantity}) => CartItemModel(
    id: id,
    title: title,
    brand: brand,
    imageUrl: imageUrl,
    unitPrice: unitPrice,
    quantity: quantity ?? this.quantity,
  );
}

class PaymentMethodModel extends PaymentMethodEntity {
  const PaymentMethodModel({
    required super.id,
    required super.type,
    required super.label,
    super.description,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) =>
      PaymentMethodModel(
        id: json['id'] as String,
        type: PaymentType.values.byName(json['type'] as String),
        label: json['label'] as String,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'label': label,
  };
}