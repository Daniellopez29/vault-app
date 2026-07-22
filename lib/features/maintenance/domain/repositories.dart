import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import 'entities.dart';

/// Contrato de acceso al historial de mantenimiento. La implementación real
/// (mock hoy, Maintenance Service después) vive en la capa data. Solo esa
/// capa cambia cuando Fernando conecte el backend.
abstract class MaintenanceRepository {
  /// Entradas de mantenimiento de un activo, más recientes primero.
  Future<Either<Failure, List<MaintenanceEntry>>> getEntriesForAsset(
    String assetId,
  );

  /// Agrega una entrada nueva y devuelve la lista actualizada.
  Future<Either<Failure, List<MaintenanceEntry>>> addEntry(
    MaintenanceEntry entry,
  );
}
