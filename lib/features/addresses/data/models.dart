import '../domain/entities.dart';

class AddressModel extends AddressEntity {
  const AddressModel({
    required super.id,
    required super.label,
    required super.recipient,
    required super.phone,
    required super.street,
    required super.city,
    required super.state,
    required super.postalCode,
    super.references = '',
    super.isDefault = false,
  });

  /// Respuesta de GET/POST /api/v1/addresses del API Go.
  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String,
      label: json['label'] as String? ?? '',
      recipient: json['recipient'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      street: json['street'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      postalCode: json['postal_code'] as String? ?? '',
      references: json['references'] as String? ?? '',
      isDefault: json['is_default'] as bool? ?? false,
    );
  }
}

/// Cuerpo para POST /api/v1/addresses -- el id lo asigna el backend, y el
/// is_default lo decide su propia lógica de negocio (primera dirección =
/// default automático), así que no se mandan.
Map<String, dynamic> addressRequestJson(AddressEntity address) => {
      'label': address.label,
      'recipient': address.recipient,
      'phone': address.phone,
      'street': address.street,
      'city': address.city,
      'state': address.state,
      'postal_code': address.postalCode,
      'references': address.references,
    };
