import '../domain/entities.dart';

class AdModel extends AdEntity {
  const AdModel({
    required super.id,
    required super.title,
    required super.description,
    required super.imageUrl,
    required super.targetSection,
    required super.targetId,
    required super.status,
  });

  /// Decodifica `AdResponse` (`GET /ads`, `POST /ads`) del backend de pagos.
  factory AdModel.fromJson(Map<String, dynamic> json) {
    return AdModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      targetSection: json['target_section'] as String? ?? '',
      targetId: json['target_id'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }
}
