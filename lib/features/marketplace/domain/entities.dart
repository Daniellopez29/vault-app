import 'package:equatable/equatable.dart';

/// Artículo publicado en el marketplace (tienda).
class MarketplaceItemEntity extends Equatable {
  final String id;
  final String brand;
  final String title;
  final String imageUrl;
  final String origin;
  final String size;
  final double price;
  final double rating;
  final bool isVerified;

  const MarketplaceItemEntity({
    required this.id,
    required this.brand,
    required this.title,
    required this.imageUrl,
    required this.origin,
    required this.size,
    required this.price,
    required this.rating,
    this.isVerified = false,
  });

  @override
  List<Object?> get props => [
    id,
    brand,
    title,
    imageUrl,
    origin,
    size,
    price,
    rating,
    isVerified,
  ];
}

/// Banner promocional que aparece en el carrusel superior del Shop.
class PromoBannerEntity extends Equatable {
  final String id;
  final String sellerName;
  final String title;
  final double price;
  final double oldPrice;
  final String imageUrl;

  const PromoBannerEntity({
    required this.id,
    required this.sellerName,
    required this.title,
    required this.price,
    required this.oldPrice,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [id, sellerName, title, price, oldPrice, imageUrl];
}