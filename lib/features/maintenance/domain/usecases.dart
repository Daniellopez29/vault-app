import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import '../../../core/usecase.dart';
import 'entities.dart';
import 'repositories.dart';

/// Obtiene el historial de mantenimiento de un activo.
class GetMaintenanceEntriesUseCase
    implements UseCase<List<MaintenanceEntry>, String> {
  final MaintenanceRepository repository;

  GetMaintenanceEntriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<MaintenanceEntry>>> call(String assetId) {
    return repository.getEntriesForAsset(assetId);
  }
}

/// Agrega una entrada nueva al historial de un activo.
class AddMaintenanceEntryUseCase
    implements UseCase<List<MaintenanceEntry>, MaintenanceEntry> {
  final MaintenanceRepository repository;

  AddMaintenanceEntryUseCase(this.repository);

  @override
  Future<Either<Failure, List<MaintenanceEntry>>> call(MaintenanceEntry entry) {
    return repository.addEntry(entry);
  }
}
