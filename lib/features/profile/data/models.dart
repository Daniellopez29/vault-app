import '../domain/entities.dart';

class AssetModel extends AssetEntity {
  const AssetModel({
    required super.id,
    required super.category,
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
    super.blockchainTxId,
    super.notes,
    super.photos,
    super.isForSale = false,
    super.salePrice,
    super.saleDescription,
    super.isPublished = false,
    super.publishCaption,
  });

  factory AssetModel.fromEntity(AssetEntity e) => AssetModel(
    id: e.id,
    category: e.category,
    brand: e.brand,
    name: e.name,
    imageUrl: e.imageUrl,
    acquisitionDate: e.acquisitionDate,
    originalPrice: e.originalPrice,
    origin: e.origin,
    size: e.size,
    condition: e.condition,
    servicesCount: e.servicesCount,
    restorationsCount: e.restorationsCount,
    isVerified: e.isVerified,
    blockchainTxId: e.blockchainTxId,
    notes: e.notes,
    photos: e.photos,
    isForSale: e.isForSale,
    salePrice: e.salePrice,
    saleDescription: e.saleDescription,
    isPublished: e.isPublished,
    publishCaption: e.publishCaption,
  );

  /// Respuesta de GET/POST/PUT /api/v1/assets del API Go. isPublished no
  /// existe en la tabla (se traduce a un post real, ver `updateAsset` en
  /// datasources.dart) -- se queda en su default (false) al leer.
  factory AssetModel.fromJson(Map<String, dynamic> json) {
    final photosJson = json['photos'] as List<dynamic>? ?? const [];
    final photos = photosJson
        .map((p) => p as Map<String, dynamic>)
        .map((p) => AssetPhotoEntity(id: p['id'] as String, url: p['url'] as String))
        .toList();
    final cover = photosJson.isNotEmpty
        ? (photosJson.firstWhere(
              (p) => (p as Map<String, dynamic>)['is_cover'] == true,
              orElse: () => photosJson.first,
            ) as Map<String, dynamic>)['url'] as String?
        : null;

    return AssetModel(
      id: json['id'] as String,
      category: AssetCategory.fromValue(json['category'] as String? ?? ''),
      brand: json['brand'] as String? ?? '',
      name: json['name'] as String,
      imageUrl: cover ?? '',
      acquisitionDate: json['purchase_date'] != null
          ? DateTime.parse(json['purchase_date'] as String)
          : DateTime.now(),
      originalPrice: (json['purchase_value'] as num?)?.toDouble() ?? 0,
      origin: json['store_origin'] as String? ?? '',
      size: json['size'] as String? ?? '',
      condition: json['condition'] as String? ?? 'nuevo',
      servicesCount: 0,
      restorationsCount: 0,
      isVerified: (json['blockchain_tx_id'] as String?)?.isNotEmpty ?? false,
      blockchainTxId: json['blockchain_tx_id'] as String?,
      notes: json['notes'] as String?,
      photos: photos,
      isForSale: json['is_for_sale'] as bool? ?? false,
      salePrice: (json['sale_price'] as num?)?.toDouble(),
      saleDescription: json['sale_description'] as String?,
    );
  }

  /// Cuerpo para POST/PUT /api/v1/assets -- solo los campos que la tabla
  /// real tiene. isPublished no se envía aquí porque se traduce a un post
  /// real (ver `updateAsset` en datasources.dart).
  Map<String, dynamic> toApiJson() => {
    'name': name,
    'category': category.value,
    'brand': brand,
    'purchase_value': originalPrice,
    'condition': condition,
    'purchase_date':
        '${acquisitionDate.year.toString().padLeft(4, '0')}-${acquisitionDate.month.toString().padLeft(2, '0')}-${acquisitionDate.day.toString().padLeft(2, '0')}',
    'store_origin': origin,
    'notes': notes ?? '',
    'size': size,
    'is_for_sale': isForSale,
    'sale_price': salePrice,
    'sale_description': saleDescription ?? '',
  };
}

class RestorerServiceModel extends RestorerServiceEntity {
  const RestorerServiceModel({
    required super.id,
    required super.title,
    required super.description,
    required super.price,
  });

  factory RestorerServiceModel.fromJson(Map<String, dynamic> json) {
    return RestorerServiceModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'price': price,
  };
}

class RestorerProfileModel extends RestorerProfileEntity {
  const RestorerProfileModel({
    required super.userId,
    required super.bio,
    required super.specialties,
    required super.services,
    super.rating,
    super.reviewsCount,
    super.name,
    super.avatarUrl,
  });

  /// Respuesta de GET/PUT /api/v1/restorerprofiles/{userId} del API Go
  /// (snake_case).
  factory RestorerProfileModel.fromJson(Map<String, dynamic> json) {
    return RestorerProfileModel(
      userId: json['user_id'] as String,
      bio: json['bio'] as String? ?? '',
      specialties: List<String>.from(json['specialties'] as List? ?? const []),
      services: (json['services'] as List<dynamic>? ?? const [])
          .map((s) => RestorerServiceModel.fromJson(s as Map<String, dynamic>))
          .toList(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: json['reviews_count'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
    );
  }
}

class BlockchainCertificateModel extends BlockchainCertificateEntity {
  const BlockchainCertificateModel({
    required super.id,
    required super.ownerId,
    required super.txId,
    required super.action,
    required super.network,
    required super.confirmedAt,
  });

  /// Decodifica `BlockchainCertificateResponse` de
  /// `GET /blockchain-certificates?asset_id=` -- lista plana, sin envoltura.
  factory BlockchainCertificateModel.fromJson(Map<String, dynamic> json) {
    return BlockchainCertificateModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      txId: json['tx_id'] as String,
      action: json['action'] as String,
      network: json['network'] as String? ?? 'testnet',
      confirmedAt: DateTime.parse(json['confirmed_at'] as String),
    );
  }
}