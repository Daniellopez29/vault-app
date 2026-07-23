import 'package:equatable/equatable.dart';

/// Una direccion de envio del usuario.
///
/// [isDefault] marca la que se usa por defecto al comprar. Solo una puede
/// serlo a la vez; la logica de exclusividad vive en el repositorio.
class AddressEntity extends Equatable {
  final String id;
  final String label;
  final String recipient;
  final String phone;
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String references;
  final bool isDefault;

  const AddressEntity({
    required this.id,
    required this.label,
    required this.recipient,
    required this.phone,
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
    this.references = '',
    this.isDefault = false,
  });

  /// Direccion en una linea, para mostrarla compacta en listas.
  String get summary {
    final parts = [street, city, state, postalCode]
        .where((p) => p.trim().isNotEmpty)
        .toList();
    return parts.join(', ');
  }

  AddressEntity copyWith({bool? isDefault}) {
    return AddressEntity(
      id: id,
      label: label,
      recipient: recipient,
      phone: phone,
      street: street,
      city: city,
      state: state,
      postalCode: postalCode,
      references: references,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  List<Object?> get props => [
        id,
        label,
        recipient,
        phone,
        street,
        city,
        state,
        postalCode,
        references,
        isDefault,
      ];
}