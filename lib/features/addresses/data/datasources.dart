import '../../../core/api_client.dart';
import '../../../core/error.dart';
import '../domain/entities.dart';
import 'models.dart';

abstract class AddressesDataSource {
  Future<List<AddressEntity>> getAddresses();
  Future<List<AddressEntity>> addAddress(AddressEntity address);
  Future<List<AddressEntity>> deleteAddress(String addressId);
  Future<List<AddressEntity>> setDefault(String addressId);
}

/// Todos los métodos devuelven la lista completa actualizada -- el backend
/// ya resuelve is_default (primera dirección = default automático, borrar
/// la default promueve otra), así que basta con re-consultar tras cada
/// escritura en vez de reconstruir el estado localmente.
class AddressesRemoteDataSourceImpl implements AddressesDataSource {
  final ApiClient _client;

  AddressesRemoteDataSourceImpl(this._client);

  @override
  Future<List<AddressEntity>> getAddresses() async {
    try {
      final body = await _client.get('/addresses');
      final list = body as List<dynamic>? ?? const [];
      return list.map((e) => AddressModel.fromJson(e as Map<String, dynamic>)).toList();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al cargar tus direcciones: $e');
    }
  }

  @override
  Future<List<AddressEntity>> addAddress(AddressEntity address) async {
    try {
      await _client.post('/addresses', body: addressRequestJson(address));
      return getAddresses();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al guardar la dirección: $e');
    }
  }

  @override
  Future<List<AddressEntity>> deleteAddress(String addressId) async {
    try {
      await _client.delete('/addresses/$addressId');
      return getAddresses();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al eliminar la dirección: $e');
    }
  }

  @override
  Future<List<AddressEntity>> setDefault(String addressId) async {
    try {
      await _client.patch('/addresses/$addressId/default');
      return getAddresses();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al actualizar la dirección: $e');
    }
  }
}