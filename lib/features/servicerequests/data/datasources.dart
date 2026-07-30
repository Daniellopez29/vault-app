import '../../../core/api_client.dart';
import '../../../core/error.dart';
import 'models.dart';

abstract class ServiceRequestsRemoteDataSource {
  Future<ServiceRequestModel> create({
    required String assetId,
    required String businessId,
    required String type,
  });
  Future<List<ServiceRequestModel>> getMine();
  Future<List<ServiceRequestModel>> getIncoming();
  Future<ServiceRequestModel> accept(String id);
  Future<ServiceRequestModel> start(String id);
  Future<ServiceRequestModel> finish(String id);
  Future<ServiceRequestModel> confirm(String id);
}

class ServiceRequestsRemoteDataSourceImpl implements ServiceRequestsRemoteDataSource {
  final ApiClient _client;

  ServiceRequestsRemoteDataSourceImpl(this._client);

  @override
  Future<ServiceRequestModel> create({
    required String assetId,
    required String businessId,
    required String type,
  }) async {
    try {
      final body = await _client.post('/service-requests', body: {
        'asset_id': assetId,
        'business_id': businessId,
        'type': type,
      });
      return ServiceRequestModel.fromJson(body as Map<String, dynamic>);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al mandar el artículo a servicio: $e');
    }
  }

  @override
  Future<List<ServiceRequestModel>> getMine() async {
    try {
      final body = await _client.get('/service-requests/mine');
      final list = body as List<dynamic>? ?? const [];
      return list.map((e) => ServiceRequestModel.fromJson(e as Map<String, dynamic>)).toList();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al cargar tus solicitudes de servicio: $e');
    }
  }

  @override
  Future<List<ServiceRequestModel>> getIncoming() async {
    try {
      final body = await _client.get('/service-requests/incoming');
      final list = body as List<dynamic>? ?? const [];
      return list.map((e) => ServiceRequestModel.fromJson(e as Map<String, dynamic>)).toList();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al cargar los artículos recibidos: $e');
    }
  }

  @override
  Future<ServiceRequestModel> accept(String id) async {
    try {
      final body = await _client.post('/service-requests/$id/accept');
      return ServiceRequestModel.fromJson(body as Map<String, dynamic>);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al aceptar la solicitud: $e');
    }
  }

  @override
  Future<ServiceRequestModel> start(String id) async {
    try {
      final body = await _client.post('/service-requests/$id/start');
      return ServiceRequestModel.fromJson(body as Map<String, dynamic>);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al iniciar el servicio: $e');
    }
  }

  @override
  Future<ServiceRequestModel> finish(String id) async {
    try {
      final body = await _client.post('/service-requests/$id/finish');
      return ServiceRequestModel.fromJson(body as Map<String, dynamic>);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al marcar como terminado: $e');
    }
  }

  @override
  Future<ServiceRequestModel> confirm(String id) async {
    try {
      final body = await _client.post('/service-requests/$id/confirm');
      return ServiceRequestModel.fromJson(body as Map<String, dynamic>);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al confirmar la recepción: $e');
    }
  }
}
