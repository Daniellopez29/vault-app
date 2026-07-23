import '../domain/entities.dart';

class MarketplaceItemModel extends MarketplaceItemEntity {
  const MarketplaceItemModel({
    required super.id,
    required super.brand,
    required super.title,
    required super.imageUrl,
    required super.origin,
    required super.size,
    required super.price,
    required super.rating,
    required super.sellerId,
    required super.sellerName,
    super.isVerified = false,
  });

  /// Respuesta de GET /api/v1/assets del API Go (solo items con
  /// is_for_sale=true llegan aquí, ver [MarketplaceRemoteDataSourceImpl]).
  /// No hay rating de vendedor individual en el backend -- queda en 0.
  factory MarketplaceItemModel.fromJson(Map<String, dynamic> json) {
    final photos = json['photos'] as List<dynamic>? ?? const [];
    final cover = photos.isNotEmpty
        ? (photos.firstWhere(
              (p) => (p as Map<String, dynamic>)['is_cover'] == true,
              orElse: () => photos.first,
            ) as Map<String, dynamic>)['url'] as String?
        : null;

    return MarketplaceItemModel(
      id: json['id'] as String,
      brand: json['brand'] as String? ?? '',
      title: json['name'] as String? ?? '',
      imageUrl: cover ?? '',
      origin: json['store_origin'] as String? ?? '',
      size: json['size'] as String? ?? '',
      price: (json['sale_price'] as num?)?.toDouble() ?? 0,
      rating: 0,
      isVerified: (json['blockchain_tx_id'] as String?)?.isNotEmpty ?? false,
      sellerId: json['user_id'] as String,
      sellerName: json['seller_name'] as String? ?? '',
    );
  }
}

class PromoBannerModel extends PromoBannerEntity {
  const PromoBannerModel({
    required super.id,
    required super.sellerName,
    required super.title,
    required super.price,
    required super.oldPrice,
    required super.imageUrl,
  });

  factory PromoBannerModel.fromJson(Map<String, dynamic> json) {
    return PromoBannerModel(
      id: json['id'] as String,
      sellerName: json['sellerName'] as String,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      oldPrice: (json['oldPrice'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sellerName': sellerName,
      'title': title,
      'price': price,
      'oldPrice': oldPrice,
      'imageUrl': imageUrl,
    };
  }
}