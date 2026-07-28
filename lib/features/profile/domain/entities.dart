import 'package:equatable/equatable.dart';

/// Categorías de activo (chips del formulario y conteo en el Perfil).
/// El nombre visible deriva de aquí, sin hardcodeo disperso.
enum AssetCategory {
  sneakers,
  caps,
  watches,
  glasses,
  bags,
  jewelry,
  collectibles,
  other;

  String get displayName {
    switch (this) {
      case AssetCategory.sneakers:     return 'Sneakers';
      case AssetCategory.caps:         return 'Gorras';
      case AssetCategory.watches:      return 'Relojes';
      case AssetCategory.glasses:      return 'Lentes';
      case AssetCategory.bags:         return 'Bolsos';
      case AssetCategory.jewelry:      return 'Visutería';
      case AssetCategory.collectibles: return 'Coleccionables';
      case AssetCategory.other:        return 'Otros';
    }
  }

  /// Debe coincidir con el CHECK constraint de `assets.category` (init.sql).
  /// El backend también admite 'carteras' y 'pulsos', sin equivalente aquí
  /// todavía -- llegan como [AssetCategory.other] al leer.
  String get value {
    switch (this) {
      case AssetCategory.sneakers:     return 'sneakers';
      case AssetCategory.caps:         return 'gorras';
      case AssetCategory.watches:      return 'relojes';
      case AssetCategory.glasses:      return 'lentes';
      case AssetCategory.bags:         return 'bolsos';
      case AssetCategory.jewelry:      return 'bisuteria';
      case AssetCategory.collectibles: return 'coleccionables';
      case AssetCategory.other:        return 'otros';
    }
  }

  static AssetCategory fromValue(String value) {
    switch (value) {
      case 'sneakers':       return AssetCategory.sneakers;
      case 'gorras':         return AssetCategory.caps;
      case 'relojes':        return AssetCategory.watches;
      case 'lentes':         return AssetCategory.glasses;
      case 'bolsos':         return AssetCategory.bags;
      case 'bisuteria':      return AssetCategory.jewelry;
      case 'coleccionables': return AssetCategory.collectibles;
      default:                return AssetCategory.other;
    }
  }
}

/// Una foto ya subida de un activo (id real, para poder borrarla).
class AssetPhotoEntity extends Equatable {
  final String id;
  final String url;

  const AssetPhotoEntity({required this.id, required this.url});

  @override
  List<Object?> get props => [id, url];
}

class AssetEntity extends Equatable {
  final String id;
  final AssetCategory category;
  final String brand;
  final String name;
  final String imageUrl;
  final DateTime acquisitionDate;
  final double originalPrice;
  final String origin;
  final String size;
  final String condition;
  final int servicesCount;
  final int restorationsCount;
  final bool isVerified;
  final String? blockchainTxId;
  final String? notes;
  final List<AssetPhotoEntity> photos;

  // ─── Estado de comunidad/comercio ───
  final bool isForSale;
  final double? salePrice;
  final String? saleDescription;
  final bool isPublished;
  final String? publishCaption;

  const AssetEntity({
    required this.id,
    required this.category,
    required this.brand,
    required this.name,
    required this.imageUrl,
    required this.acquisitionDate,
    required this.originalPrice,
    required this.origin,
    required this.size,
    required this.condition,
    required this.servicesCount,
    required this.restorationsCount,
    this.isVerified = false,
    this.blockchainTxId,
    this.notes,
    this.photos = const [],
    this.isForSale = false,
    this.salePrice,
    this.saleDescription,
    this.isPublished = false,
    this.publishCaption,
  });

  AssetEntity copyWith({
    String? name,
    AssetCategory? category,
    String? brand,
    DateTime? acquisitionDate,
    double? originalPrice,
    String? origin,
    String? size,
    String? condition,
    String? notes,
    bool? isForSale,
    double? salePrice,
    String? saleDescription,
    bool? isPublished,
    String? publishCaption,
  }) {
    return AssetEntity(
      id: id,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      name: name ?? this.name,
      imageUrl: imageUrl,
      acquisitionDate: acquisitionDate ?? this.acquisitionDate,
      originalPrice: originalPrice ?? this.originalPrice,
      origin: origin ?? this.origin,
      size: size ?? this.size,
      condition: condition ?? this.condition,
      servicesCount: servicesCount,
      restorationsCount: restorationsCount,
      isVerified: isVerified,
      blockchainTxId: blockchainTxId,
      notes: notes ?? this.notes,
      photos: photos,
      isForSale: isForSale ?? this.isForSale,
      salePrice: salePrice ?? this.salePrice,
      saleDescription: saleDescription ?? this.saleDescription,
      isPublished: isPublished ?? this.isPublished,
      publishCaption: publishCaption ?? this.publishCaption,
    );
  }

  @override
  List<Object?> get props => [
    id, category, brand, name, imageUrl, acquisitionDate, originalPrice,
    origin, size, condition, servicesCount, restorationsCount, isVerified,
    blockchainTxId, notes, photos, isForSale, salePrice, saleDescription,
    isPublished, publishCaption,
  ];
}

/// Una foto seleccionada en el dispositivo, pendiente de subir. Mismo
/// patrón que `PostImageUpload` (ver `features/home/domain/repositories.dart`).
class AssetImageUpload {
  final List<int> bytes;
  final String filename;

  const AssetImageUpload({required this.bytes, required this.filename});
}

class RestorerServiceEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final double price;

  const RestorerServiceEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
  });

  @override
  List<Object?> get props => [id, title, description, price];
}

class RestorerProfileEntity extends Equatable {
  final String userId;
  final String bio;
  final List<String> specialties;
  final List<RestorerServiceEntity> services;
  final double rating;
  final int reviewsCount;
  final String name;
  final String avatarUrl;

  const RestorerProfileEntity({
    required this.userId,
    required this.bio,
    required this.specialties,
    required this.services,
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.name = '',
    this.avatarUrl = '',
  });

  @override
  List<Object?> get props =>
      [userId, bio, specialties, services, rating, reviewsCount, name, avatarUrl];
}