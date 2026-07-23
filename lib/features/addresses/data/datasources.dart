import '../domain/entities.dart';

/// Fuente de datos de direcciones. Mock en memoria mientras el backend no
/// exponga los endpoints correspondientes.
abstract class AddressesDataSource {
  Future<List<AddressEntity>> getAddresses();
  Future<List<AddressEntity>> addAddress(AddressEntity address);
  Future<List<AddressEntity>> deleteAddress(String addressId);
  Future<List<AddressEntity>> setDefault(String addressId);
}

class AddressesMockDataSource implements AddressesDataSource {
  final List<AddressEntity> _store = [];

  @override
  Future<List<AddressEntity>> getAddresses() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.of(_store);
  }

  @override
  Future<List<AddressEntity>> addAddress(AddressEntity address) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // La primera direccion queda como predeterminada automaticamente.
    final isFirst = _store.isEmpty;
    _store.add(address.copyWith(isDefault: isFirst || address.isDefault));
    if (address.isDefault && !isFirst) {
      _applyDefault(address.id);
    }
    return List.of(_store);
  }

  @override
  Future<List<AddressEntity>> deleteAddress(String addressId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _store.removeWhere((a) => a.id == addressId);
    // Si se borro la predeterminada, la primera restante toma el lugar.
    if (_store.isNotEmpty && !_store.any((a) => a.isDefault)) {
      _applyDefault(_store.first.id);
    }
    return List.of(_store);
  }

  @override
  Future<List<AddressEntity>> setDefault(String addressId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _applyDefault(addressId);
    return List.of(_store);
  }

  /// Deja una sola direccion marcada como predeterminada.
  void _applyDefault(String addressId) {
    for (var i = 0; i < _store.length; i++) {
      _store[i] = _store[i].copyWith(isDefault: _store[i].id == addressId);
    }
  }
}