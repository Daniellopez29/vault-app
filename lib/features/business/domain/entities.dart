import 'package:equatable/equatable.dart';

/// El negocio del usuario actual. `api/` no tiene campo de horarios todavía
/// (ver `Business` entity en Go) -- nombre, tipo, descripción, ubicación y
/// fotos.
class BusinessEntity extends Equatable {
  final String id;
  final String name;
  final List<String> types;
  final String description;
  final String location;
  final bool isVerified;
  final List<String> specialties;

  /// URLs de las fotos ya subidas, en el orden en que se guardaron. La
  /// primera es la portada (ver `businesses_tab.dart`).
  final List<String> photos;

  const BusinessEntity({
    required this.id,
    required this.name,
    required this.types,
    required this.description,
    required this.location,
    required this.isVerified,
    this.specialties = const [],
    this.photos = const [],
  });

  BusinessEntity copyWith({String? location, List<String>? specialties}) {
    return BusinessEntity(
      id: id,
      name: name,
      types: types,
      description: description,
      location: location ?? this.location,
      isVerified: isVerified,
      specialties: specialties ?? this.specialties,
      photos: photos,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, types, description, location, isVerified, specialties, photos];
}
