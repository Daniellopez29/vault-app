import 'package:equatable/equatable.dart';

/// El negocio del usuario actual. `api/` no tiene campos de horarios ni
/// fotos todavía (ver `Business` entity en Go) -- solo nombre, tipo,
/// descripción y ubicación.
class BusinessEntity extends Equatable {
  final String id;
  final String name;
  final String type;
  final String description;
  final String location;
  final bool isVerified;

  const BusinessEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.location,
    required this.isVerified,
  });

  BusinessEntity copyWith({String? location}) {
    return BusinessEntity(
      id: id,
      name: name,
      type: type,
      description: description,
      location: location ?? this.location,
      isVerified: isVerified,
    );
  }

  @override
  List<Object?> get props => [id, name, type, description, location, isVerified];
}
