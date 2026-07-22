import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';
import 'datasources.dart';
import 'models.dart';

/// Implementación del repositorio. Envuelve el datasource en Either/Failure,
/// igual que el resto de la app.
class MaintenanceRepositoryImpl implements MaintenanceRepository {
  final MaintenanceDataSource dataSource;

  MaintenanceRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, List<MaintenanceEntry>>> getEntriesForAsset(
    String assetId,
  ) async {
    try {
      final entries = await dataSource.getEntriesForAsset(assetId);
      return Right(entries);
    } catch (_) {
      return const Left(ServerFailure('Error al cargar el mantenimiento.'));
    }
  }

  @override
  Future<Either<Failure, List<MaintenanceEntry>>> addEntry(
    MaintenanceEntry entry,
  ) async {
    try {
      final model = MaintenanceEntryModel.fromEntity(entry);
      final entries = await dataSource.addEntry(model);
      return Right(entries);
    } catch (_) {
      return const Left(ServerFailure('Error al agregar el mantenimiento.'));
    }
  }
}
