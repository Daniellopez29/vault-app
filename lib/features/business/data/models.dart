import '../domain/entities.dart';

class BusinessModel extends BusinessEntity {
  const BusinessModel({
    required super.id,
    required super.name,
    required super.type,
    required super.description,
    required super.location,
    required super.isVerified,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      description: json['description'] as String? ?? '',
      location: json['location'] as String? ?? '',
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }

  /// Body para `PUT /businesses/{id}` -- el backend exige los 4 campos
  /// juntos aunque solo cambie uno.
  Map<String, dynamic> toRequestJson() => {
        'name': name,
        'type': type,
        'description': description,
        'location': location,
      };
}
