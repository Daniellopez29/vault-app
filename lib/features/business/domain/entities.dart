import 'package:equatable/equatable.dart';

/// El negocio del usuario actual. `api/` no tiene campos de horarios ni
/// fotos todavía (ver `Business` entity en Go) -- solo nombre, tipo,
/// descripción y ubicación.
class BusinessEntity extends Equatable {
  final String id;
  final String name;
  final List<String> types;
  final String description;
  final String location;
  final bool isVerified;
  final List<String> specialties;

  const BusinessEntity({
    required this.id,
    required this.name,
    required this.types,
    required this.description,
    required this.location,
    required this.isVerified,
    this.specialties = const [],
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
    );
  }

  @override
  List<Object?> get props =>
      [id, name, types, description, location, isVerified, specialties];
}
