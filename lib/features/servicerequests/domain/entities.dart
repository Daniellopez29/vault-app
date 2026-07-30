import 'package:equatable/equatable.dart';

/// Deben coincidir con `entities.ServiceRequestType*` en
/// `api/src/features/servicerequests/domain/entities/ServiceRequest.go`.
abstract class ServiceRequestType {
  static const servicio = 'servicio';
  static const reparacion = 'reparacion';
}

/// Deben coincidir con `entities.ServiceRequestStatus*` en el mismo archivo.
abstract class ServiceRequestStatus {
  static const pendienteAceptacion = 'pendiente_aceptacion';
  static const enEspera = 'en_espera';
  static const enServicio = 'en_servicio';
  static const terminado = 'terminado';
  static const confirmado = 'confirmado';
}

/// Solicitud de servicio/reparación iniciada desde el chat: el dueño manda
/// un activo a un negocio y ambos avanzan el estado hasta que el dueño
/// confirma que lo recibió de vuelta.
class ServiceRequestEntity extends Equatable {
  final String id;
  final String assetId;
  final String assetName;
  final String assetImageUrl;
  final String ownerId;
  final String ownerName;
  final String businessId;
  final String businessName;
  final String type;
  final String status;
  final DateTime createdAt;

  const ServiceRequestEntity({
    required this.id,
    required this.assetId,
    required this.assetName,
    required this.assetImageUrl,
    required this.ownerId,
    required this.ownerName,
    required this.businessId,
    required this.businessName,
    required this.type,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        assetId,
        assetName,
        assetImageUrl,
        ownerId,
        ownerName,
        businessId,
        businessName,
        type,
        status,
        createdAt,
      ];
}
