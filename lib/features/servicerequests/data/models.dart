import '../domain/entities.dart';

class ServiceRequestModel extends ServiceRequestEntity {
  const ServiceRequestModel({
    required super.id,
    required super.assetId,
    required super.assetName,
    required super.assetImageUrl,
    required super.ownerId,
    required super.ownerName,
    required super.businessId,
    required super.businessName,
    required super.type,
    required super.status,
    required super.createdAt,
  });

  /// Decodifica `ServiceRequestResponse` de api/ -- misma forma en todas las
  /// rutas de `/service-requests` (crear, aceptar/iniciar/terminar/
  /// confirmar, y ambos listados).
  factory ServiceRequestModel.fromJson(Map<String, dynamic> json) {
    return ServiceRequestModel(
      id: json['id'] as String,
      assetId: json['asset_id'] as String,
      assetName: json['asset_name'] as String? ?? '',
      assetImageUrl: json['asset_image_url'] as String? ?? '',
      ownerId: json['owner_id'] as String,
      ownerName: json['owner_name'] as String? ?? '',
      businessId: json['business_id'] as String,
      businessName: json['business_name'] as String? ?? '',
      type: json['type'] as String,
      status: json['status'] as String,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
