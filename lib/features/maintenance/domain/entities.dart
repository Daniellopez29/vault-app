import 'package:equatable/equatable.dart';

/// Tipo de mantenimiento realizado a un activo.
/// Distingue servicio (limpieza, ajuste) de restauración, coherente con los
/// campos servicesCount / restorationsCount de AssetEntity.
enum MaintenanceType {
  cleaning,
  repair,
  restoration,
  inspection,
  other;

  String get displayName {
    switch (this) {
      case MaintenanceType.cleaning:    return 'Limpieza';
      case MaintenanceType.repair:      return 'Reparación';
      case MaintenanceType.restoration: return 'Restauración';
      case MaintenanceType.inspection:  return 'Revisión';
      case MaintenanceType.other:       return 'Otro';
    }
  }

  /// Valor estable para persistir (debe coincidir con el backend cuando
  /// exista el Maintenance Service). Sin hardcodeo disperso en la UI.
  String get value {
    switch (this) {
      case MaintenanceType.cleaning:    return 'cleaning';
      case MaintenanceType.repair:      return 'repair';
      case MaintenanceType.restoration: return 'restoration';
      case MaintenanceType.inspection:  return 'inspection';
      case MaintenanceType.other:       return 'other';
    }
  }

  static MaintenanceType fromValue(String value) {
    switch (value) {
      case 'cleaning':    return MaintenanceType.cleaning;
      case 'repair':      return MaintenanceType.repair;
      case 'restoration': return MaintenanceType.restoration;
      case 'inspection':  return MaintenanceType.inspection;
      default:            return MaintenanceType.other;
    }
  }
}

/// Una entrada del historial de mantenimiento de un activo.
/// Le da trazabilidad a lo que antes eran solo contadores.
class MaintenanceEntry extends Equatable {
  final String id;
  final String assetId;
  final MaintenanceType type;
  final DateTime date;
  final String description;
  final double? cost;

  const MaintenanceEntry({
    required this.id,
    required this.assetId,
    required this.type,
    required this.date,
    required this.description,
    this.cost,
  });

  @override
  List<Object?> get props => [id, assetId, type, date, description, cost];
}
