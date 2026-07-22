import '../domain/entities.dart';

/// Modelo de datos de una entrada de mantenimiento. Sabe construirse desde
/// y hacia un mapa (como el que envía/recibe /maintenance-logs).
class MaintenanceEntryModel extends MaintenanceEntry {
  const MaintenanceEntryModel({
    required super.id,
    required super.assetId,
    required super.type,
    required super.date,
    required super.description,
    super.cost,
  });

  factory MaintenanceEntryModel.fromMap(Map<String, dynamic> map) {
    return MaintenanceEntryModel(
      id: map['id'] as String,
      assetId: map['assetId'] as String,
      type: MaintenanceType.fromValue(map['type'] as String),
      date: DateTime.parse(map['date'] as String),
      description: map['description'] as String,
      cost: (map['cost'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'assetId': assetId,
        'type': type.value,
        'date': date.toIso8601String(),
        'description': description,
        'cost': cost,
      };

  factory MaintenanceEntryModel.fromEntity(MaintenanceEntry e) {
    return MaintenanceEntryModel(
      id: e.id,
      assetId: e.assetId,
      type: e.type,
      date: e.date,
      description: e.description,
      cost: e.cost,
    );
  }

  /// Decodifica la respuesta real de `GET/POST /maintenance-logs`. El
  /// backend solo conoce dos categorías (`mantenimiento`/`restauracion`) --
  /// el subtipo exacto de la app (limpieza, reparación, revisión, etc.) se
  /// guarda en `subtype` para poder reconstruir el `MaintenanceType` original;
  /// si viene un subtype que no reconocemos (dato viejo o de otro cliente),
  /// cae en el tipo derivado de la categoría del backend.
  factory MaintenanceEntryModel.fromJson(Map<String, dynamic> json) {
    final subtype = json['subtype'] as String?;
    final backendType = json['type'] as String? ?? 'mantenimiento';
    final type = (subtype != null && subtype.isNotEmpty)
        ? MaintenanceType.fromValue(subtype)
        : (backendType == 'restauracion' ? MaintenanceType.restoration : MaintenanceType.other);

    final performedAt = json['performed_at'] as String?;
    final date = performedAt != null && performedAt.isNotEmpty
        ? DateTime.parse(performedAt)
        : DateTime.parse(json['created_at'] as String);

    return MaintenanceEntryModel(
      id: json['id'] as String,
      assetId: json['asset_id'] as String,
      type: type,
      date: date,
      description: json['notes'] as String? ?? '',
      cost: (json['cost'] as num?)?.toDouble(),
    );
  }

  /// Body para `POST /maintenance-logs`.
  Map<String, dynamic> toRequestJson() => {
        'asset_id': assetId,
        'type': type == MaintenanceType.restoration ? 'restauracion' : 'mantenimiento',
        'subtype': type.value,
        'cost': cost,
        'performed_at':
            '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        'notes': description,
      };
}