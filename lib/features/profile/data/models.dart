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
    super.notes,
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
    notes: e.notes,
    isForSale: e.isForSale,
    salePrice: e.salePrice,
    saleDescription: e.saleDescription,
    isPublished: e.isPublished,
    publishCaption: e.publishCaption,
  );

  /// Respuesta de GET/POST/PUT /api/v1/assets del API Go. isForSale/
  /// salePrice/saleDescription/isPublished/size no existen en la tabla real
  /// -- quedan en sus valores por defecto (false/null/vacío) al leer.
  factory AssetModel.fromJson(Map<String, dynamic> json) {
    final photos = json['photos'] as List<dynamic>? ?? const [];
    final cover = photos.isNotEmpty
        ? (photos.firstWhere(
              (p) => (p as Map<String, dynamic>)['is_cover'] == true,
              orElse: () => photos.first,
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
      size: '',
      condition: json['condition'] as String? ?? 'nuevo',
      servicesCount: 0,
      restorationsCount: 0,
      isVerified: (json['blockchain_tx_id'] as String?)?.isNotEmpty ?? false,
      notes: json['notes'] as String?,
    );
  }

  /// Cuerpo para POST/PUT /api/v1/assets -- solo los campos que la tabla
  /// real tiene. isForSale/salePrice/saleDescription/isPublished/size no
  /// se envían porque el backend no los persiste.
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
  });

  factory RestorerProfileModel.fromJson(Map<String, dynamic> json) {
    return RestorerProfileModel(
      userId: json['userId'] as String,
      bio: json['bio'] as String,
      specialties: List<String>.from(json['specialties'] as List),
      services: (json['services'] as List)
          .map((s) => RestorerServiceModel.fromJson(s as Map<String, dynamic>))
          .toList(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: json['reviewsCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'bio': bio,
    'specialties': specialties,
    'services': services
        .map((s) => RestorerServiceModel(
      id: s.id,
      title: s.title,
      description: s.description,
      price: s.price,
    ).toJson())
        .toList(),
    'rating': rating,
    'reviewsCount': reviewsCount,
  };
}