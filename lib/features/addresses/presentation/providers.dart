import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources.dart';
import '../data/repositories.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';

// Datasource compartido: una sola instancia para que lo agregado persista
// durante la sesion (es mock en memoria).
final _addressesDataSourceProvider = Provider<AddressesDataSource>((ref) {
  return AddressesMockDataSource();
});

final addressesRepositoryProvider = Provider<AddressesRepository>((ref) {
  return AddressesRepositoryImpl(
    dataSource: ref.read(_addressesDataSourceProvider),
  );
});

enum AddressesStatus { loading, loaded, error }

class AddressesState {
  final AddressesStatus status;
  final List<AddressEntity> addresses;
  final String? errorMessage;

  const AddressesState({
    this.status = AddressesStatus.loading,
    this.addresses = const [],
    this.errorMessage,
  });

  AddressesState copyWith({
    AddressesStatus? status,
    List<AddressEntity>? addresses,
    String? errorMessage,
  }) {
    return AddressesState(
      status: status ?? this.status,
      addresses: addresses ?? this.addresses,
      errorMessage: errorMessage,
    );
  }
}

class AddressesController extends StateNotifier<AddressesState> {
  final AddressesRepository _repository;

  AddressesController(this._repository) : super(const AddressesState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(status: AddressesStatus.loading);
    final result = await _repository.getAddresses();
    _apply(result);
  }

  Future<void> add(AddressEntity address) async {
    _apply(await _repository.addAddress(address));
  }

  Future<void> remove(String addressId) async {
    _apply(await _repository.deleteAddress(addressId));
  }

  Future<void> setDefault(String addressId) async {
    _apply(await _repository.setDefault(addressId));
  }

  /// Aplica el resultado al estado, en un solo lugar.
  void _apply(dynamic result) {
    result.fold(
      (failure) => state = state.copyWith(
        status: AddressesStatus.error,
        errorMessage: failure.message,
      ),
      (addresses) => state = state.copyWith(
        status: AddressesStatus.loaded,
        addresses: addresses,
      ),
    );
  }
}

final addressesControllerProvider =
    StateNotifierProvider<AddressesController, AddressesState>((ref) {
  return AddressesController(ref.read(addressesRepositoryProvider));
});