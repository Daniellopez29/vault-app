import 'package:equatable/equatable.dart';
import '../../ads/domain/entities.dart';
import '../../subscription/domain/entities.dart';

/// ArtÃ­culo publicado en el marketplace (tienda).
class MarketplaceItemEntity extends Equatable {
  final String id;
  final String brand;
  final String title;
  final String imageUrl;
  final String origin;
  final String size;
  final double price;
  final double rating;
  final int totalReviews;
  final int servicesCount;
  final int restorationsCount;
  final bool isVerified;
  final String sellerId;
  final String sellerName;

  const MarketplaceItemEntity({
    required this.id,
    required this.brand,
    required this.title,
    required this.imageUrl,
    required this.origin,
    required this.size,
    required this.price,
    required this.rating,
    required this.sellerId,
    required this.sellerName,
    this.totalReviews = 0,
    this.servicesCount = 0,
    this.restorationsCount = 0,
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
    totalReviews,
    servicesCount,
    restorationsCount,
    isVerified,
    sellerId,
    sellerName,
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
/// Slides del carrusel del Shop. Un slide puede ser una promo de producto
/// o un anuncio de suscripciÃ³n. Se usa sealed class para que el carrusel
/// tenga que cubrir todos los tipos (el compilador obliga), evitando ifs
/// sueltos y facilitando agregar tipos nuevos sin romper nada.
///
/// PromoBannerEntity NO se toca: PromoSlide solo la envuelve.
sealed class CarouselSlide extends Equatable {
  const CarouselSlide();
}

/// Slide que muestra una promociÃ³n de un producto (banner existente).
class PromoSlide extends CarouselSlide {
  final PromoBannerEntity banner;

  const PromoSlide(this.banner);

  @override
  List<Object?> get props => [banner];
}

/// Slide que invita a contratar una suscripciÃ³n. No es un dato del backend:
/// es un CTA fijo de la app. Lleva el tipo para saber a quÃ© suscripciÃ³n
/// dirige (producto o negocio); el texto se resuelve desde SubscriptionCopy.
class SubscriptionSlide extends CarouselSlide {
  final SubscriptionType type;

  const SubscriptionSlide(this.type);

  @override
  List<Object?> get props => [type];
}

/// Slide que muestra un anuncio real, pagado por un vendedor/negocio (ver
/// `features/ads/`). Se agrega junto a los demás cuando hay anuncios
/// activos en la sección "marketplace".
class AdSlide extends CarouselSlide {
  final AdEntity ad;

  const AdSlide(this.ad);

  @override
  List<Object?> get props => [ad];
}

