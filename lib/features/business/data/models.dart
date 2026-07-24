import '../domain/entities.dart';

class BusinessModel extends BusinessEntity {
  const BusinessModel({
    required super.id,
    super.userId,
    required super.name,
    required super.types,
    required super.description,
    required super.location,
    required super.isVerified,
    super.specialties,
    super.photos,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    final photosJson = json['photos'] as List<dynamic>? ?? const [];
    return BusinessModel(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      name: json['name'] as String,
      types: List<String>.from(json['types'] as List? ?? const []),
      description: json['description'] as String? ?? '',
      location: json['location'] as String? ?? '',
      isVerified: json['is_verified'] as bool? ?? false,
      specialties: List<String>.from(json['specialties'] as List? ?? const []),
      photos: photosJson
          .map((p) => p as Map<String, dynamic>)
          .map((p) => BusinessPhotoEntity(id: p['id'] as String, url: p['url'] as String))
          .toList(),
    );
  }

  /// Body para `PUT /businesses/{id}` -- el backend exige los campos juntos
  /// aunque solo cambie uno (si se omite `specialties` se sobreescribe con
  /// vacío, así que siempre se manda con el valor actual).
  Map<String, dynamic> toRequestJson() => {
        'name': name,
        'types': types,
        'description': description,
        'location': location,
        'specialties': specialties,
      };
}
