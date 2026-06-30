import '../domain/entities.dart';

class AssetModel extends AssetEntity {
  const AssetModel({
    required super.id,
    required super.brand,
    required super.name,
    required super.imageUrl,
    required super.acquisitionDate,
    required super.originalPrice,
    required super.origin,
    required super.size,
    required super.condition,
    required super.servicesCount,
    required super.restorationsCount,
    super.isVerified = false,
  });

  factory AssetModel.fromJson(Map<String, dynamic> json) {
    return AssetModel(
      id: json['id'] as String,
      brand: json['brand'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      acquisitionDate: DateTime.parse(json['acquisitionDate'] as String),
      originalPrice: (json['originalPrice'] as num).toDouble(),
      origin: json['origin'] as String,
      size: json['size'] as String,
      condition: json['condition'] as String,
      servicesCount: json['servicesCount'] as int,
      restorationsCount: json['restorationsCount'] as int,
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'name': name,
      'imageUrl': imageUrl,
      'acquisitionDate': acquisitionDate.toIso8601String(),
      'originalPrice': originalPrice,
      'origin': origin,
      'size': size,
      'condition': condition,
      'servicesCount': servicesCount,
      'restorationsCount': restorationsCount,
      'isVerified': isVerified,
    };
  }
}