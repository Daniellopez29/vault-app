import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources.dart';
import '../data/repositories.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';
import '../domain/usecases.dart';

// Datasource mock compartido (una sola instancia, para que las entradas
// agregadas en memoria persistan durante la sesión).
final _maintenanceDataSourceProvider = Provider<MaintenanceDataSource>((ref) {
  return MaintenanceMockDataSource();
});

final maintenanceRepositoryProvider = Provider<MaintenanceRepository>((ref) {
  return MaintenanceRepositoryImpl(
    dataSource: ref.read(_maintenanceDataSourceProvider),
  );
});

final getMaintenanceEntriesUseCaseProvider =
    Provider<GetMaintenanceEntriesUseCase>((ref) {
  return GetMaintenanceEntriesUseCase(ref.read(maintenanceRepositoryProvider));
});

final addMaintenanceEntryUseCaseProvider =
    Provider<AddMaintenanceEntryUseCase>((ref) {
  return AddMaintenanceEntryUseCase(ref.read(maintenanceRepositoryProvider));
});

enum MaintenanceStatus { loading, loaded, error }

class MaintenanceState {
  final MaintenanceStatus status;
  final List<MaintenanceEntry> entries;
  final String? errorMessage;

  const MaintenanceState({
    this.status = MaintenanceStatus.loading,
    this.entries = const [],
    this.errorMessage,
  });

  MaintenanceState copyWith({
    MaintenanceStatus? status,
    List<MaintenanceEntry>? entries,
    String? errorMessage,
  }) {
    return MaintenanceState(
      status: status ?? this.status,
      entries: entries ?? this.entries,
      errorMessage: errorMessage,
    );
  }
}

/// Controla el historial de un activo concreto. El assetId se fija al crear
/// el controller (viene del detalle del activo).
class MaintenanceController extends StateNotifier<MaintenanceState> {
  final GetMaintenanceEntriesUseCase _getEntries;
  final AddMaintenanceEntryUseCase _addEntry;
  final String assetId;

  MaintenanceController(this._getEntries, this._addEntry, this.assetId)
      : super(const MaintenanceState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(status: MaintenanceStatus.loading);
    final result = await _getEntries(assetId);
    result.fold(
      (failure) => state = state.copyWith(
        status: MaintenanceStatus.error,
        errorMessage: failure.message,
      ),
      (entries) => state = state.copyWith(
        status: MaintenanceStatus.loaded,
        entries: entries,
      ),
    );
  }

  Future<bool> addEntry(MaintenanceEntry entry) async {
    final result = await _addEntry(entry);
    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (entries) {
        state = state.copyWith(
          status: MaintenanceStatus.loaded,
          entries: entries,
        );
        return true;
      },
    );
  }
}

/// Family: un controller por activo, para que cada activo tenga su historial.
final maintenanceControllerProvider = StateNotifierProvider.family<
    MaintenanceController, MaintenanceState, String>((ref, assetId) {
  return MaintenanceController(
    ref.read(getMaintenanceEntriesUseCaseProvider),
    ref.read(addMaintenanceEntryUseCaseProvider),
    assetId,
  );
});

