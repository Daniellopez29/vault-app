import 'package:equatable/equatable.dart';

/// Secciones donde puede aparecer un anuncio (ver `ValidSections` en
/// `payment/src/features/ads/domain/entities/Ad.go`).
abstract class AdSection {
  static const marketplace = 'marketplace';
  static const feed = 'feed';
}

/// Un anuncio pagado, ya activo, listo para mostrarse. Espeja `AdResponse`
/// del backend -- el dueño/suscripción no se exponen al cliente porque
/// cualquier usuario puede listar los anuncios activos de una sección.
class AdEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String targetSection;
  final String targetId;
  final String status;

  const AdEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.targetSection,
    required this.targetId,
    required this.status,
  });

  @override
  List<Object?> get props =>
      [id, title, description, imageUrl, targetSection, targetId, status];
}
