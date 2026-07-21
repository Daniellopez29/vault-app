import '../domain/entities.dart';

/// Modelo de datos de una entrada de mantenimiento. Sabe construirse desde
/// y hacia un mapa (como el que enviará/recibirá el Maintenance Service).
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
}
