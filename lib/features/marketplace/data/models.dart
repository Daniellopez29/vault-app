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
    super.isVerified = false,
  });

  factory MarketplaceItemModel.fromJson(Map<String, dynamic> json) {
    return MarketplaceItemModel(
      id: json['id'] as String,
      brand: json['brand'] as String,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String,
      origin: json['origin'] as String,
      size: json['size'] as String,
      price: (json['price'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'title': title,
      'imageUrl': imageUrl,
      'origin': origin,
      'size': size,
      'price': price,
      'rating': rating,
      'isVerified': isVerified,
    };
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