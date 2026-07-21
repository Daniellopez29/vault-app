import '../domain/entities.dart';
import 'models.dart';

/// Fuente de datos del mantenimiento. Hoy es mock en memoria; mañana será el
/// Maintenance Service. Aislado aquí para que el cambio a backend toque SOLO
/// este archivo.
abstract class MaintenanceDataSource {
  Future<List<MaintenanceEntryModel>> getEntriesForAsset(String assetId);
  Future<List<MaintenanceEntryModel>> addEntry(MaintenanceEntryModel entry);
}

class MaintenanceMockDataSource implements MaintenanceDataSource {
  // Almacén en memoria: assetId -> lista de entradas. Se pierde al reiniciar
  // (es mock). Precargado con ejemplos para algunos activos.
  final Map<String, List<MaintenanceEntryModel>> _store = {};

  MaintenanceMockDataSource() {
    _seed();
  }

  @override
  Future<List<MaintenanceEntryModel>> getEntriesForAsset(String assetId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final list = _store[assetId] ?? [];
    // Más recientes primero.
    final sorted = [...list]..sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  @override
  Future<List<MaintenanceEntryModel>> addEntry(
    MaintenanceEntryModel entry,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final list = _store.putIfAbsent(entry.assetId, () => []);
    list.add(entry);
    final sorted = [...list]..sort((a, b) => b.date.compareTo(a.date));
    _store[entry.assetId] = sorted;
    return sorted;
  }

  /// Datos de ejemplo para que el historial no salga vacío en la demo.
  void _seed() {
    _store['1'] = [
      MaintenanceEntryModel(
        id: 'm1',
        assetId: '1',
        type: MaintenanceType.cleaning,
        date: DateTime.now().subtract(const Duration(days: 30)),
        description: 'Limpieza profunda de suela y malla.',
        cost: 150,
      ),
      MaintenanceEntryModel(
        id: 'm2',
        assetId: '1',
        type: MaintenanceType.restoration,
        date: DateTime.now().subtract(const Duration(days: 90)),
        description: 'Restauración de color y reforzado de costuras.',
        cost: 480,
      ),
    ];
  }
}
