import '../../../core/api_client.dart';
import '../../../core/error.dart';
import 'models.dart';

abstract class MaintenanceDataSource {
  Future<List<MaintenanceEntryModel>> getEntriesForAsset(String assetId);
  Future<List<MaintenanceEntryModel>> addEntry(MaintenanceEntryModel entry);
}

/// Consume `api/`'s `maintenance-logs` (ya desplegado y expuesto vía el
/// gateway). `GET` es público, `POST` requiere el owner del asset.
class MaintenanceRemoteDataSource implements MaintenanceDataSource {
  final ApiClient _client;

  MaintenanceRemoteDataSource(this._client);

  @override
  Future<List<MaintenanceEntryModel>> getEntriesForAsset(String assetId) async {
    try {
      final body = await _client
          .get('/maintenance-logs', query: {'asset_id': assetId}, auth: false);
      final list = body as List<dynamic>? ?? const [];
      final entries = list
          .map((e) => MaintenanceEntryModel.fromJson(e as Map<String, dynamic>))
          .toList();
      entries.sort((a, b) => b.date.compareTo(a.date));
      return entries;
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al cargar el mantenimiento: $e');
    }
  }

  @override
  Future<List<MaintenanceEntryModel>> addEntry(MaintenanceEntryModel entry) async {
    try {
      await _client.post('/maintenance-logs', body: entry.toRequestJson());
      return getEntriesForAsset(entry.assetId);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al agregar el mantenimiento: $e');
    }
  }
}
