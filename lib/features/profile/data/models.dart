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

  Map<String, dynamic> toJson() => {
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