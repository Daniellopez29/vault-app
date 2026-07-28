import 'package:equatable/equatable.dart';

/// Una foto ya subida de un negocio (id real, para poder borrarla).
class BusinessPhotoEntity extends Equatable {
  final String id;
  final String url;

  const BusinessPhotoEntity({required this.id, required this.url});

  @override
  List<Object?> get props => [id, url];
}

/// El negocio del usuario actual. `api/` no tiene campo de horarios todavía
/// (ver `Business` entity en Go) -- nombre, tipo, descripción, ubicación y
/// fotos.
class BusinessEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final List<String> types;
  final String description;
  final String location;
  final bool isVerified;
  final List<String> specialties;

  /// Fotos ya subidas, en el orden en que se guardaron. La primera es la
  /// portada (ver `businesses_tab.dart`).
  final List<BusinessPhotoEntity> photos;

  const BusinessEntity({
    required this.id,
    this.userId = '',
    required this.name,
    required this.types,
    required this.description,
    required this.location,
    required this.isVerified,
    this.specialties = const [],
    this.photos = const [],
  });

  BusinessEntity copyWith({
    String? name,
    List<String>? types,
    String? description,
    String? location,
    List<String>? specialties,
  }) {
    return BusinessEntity(
      id: id,
      userId: userId,
      name: name ?? this.name,
      types: types ?? this.types,
      description: description ?? this.description,
      location: location ?? this.location,
      isVerified: isVerified,
      specialties: specialties ?? this.specialties,
      photos: photos,
    );
  }

  @override
  List<Object?> get props =>
      [id, userId, name, types, description, location, isVerified, specialties, photos];
}

/// Un servicio del catálogo de un negocio (`businesses/{id}/services`), ej.
/// "Limpieza de sneakers" con su precio.
class BusinessServiceEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final double price;

  const BusinessServiceEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
  });

  @override
  List<Object?> get props => [id, title, description, price];
}
