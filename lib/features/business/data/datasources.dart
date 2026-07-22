import '../../../core/api_client.dart';
import '../../../core/error.dart';
import 'models.dart';

abstract class BusinessRemoteDataSource {
  Future<BusinessModel?> getMyBusiness();
  Future<BusinessModel> updateBusiness(String id, BusinessModel business);
}

/// [currentUserId] filtra `GET /businesses` (que devuelve los de todos los
/// usuarios) a solo el del dueño de la sesión -- el backend no tiene un
/// endpoint "mi negocio" todavía (mismo patrón que `ProfileRemoteDataSource`
/// usa para "mis activos").
class BusinessRemoteDataSourceImpl implements BusinessRemoteDataSource {
  final ApiClient _client;
  final String? Function() _currentUserId;

  BusinessRemoteDataSourceImpl(this._client, {required String? Function() currentUserId})
      : _currentUserId = currentUserId;

  @override
  Future<BusinessModel?> getMyBusiness() async {
    try {
      final body = await _client.get('/businesses', auth: false);
      final list = body as List<dynamic>? ?? const [];
      final userId = _currentUserId();
      if (userId == null) return null;
      final mine = list
          .map((e) => e as Map<String, dynamic>)
          .where((json) => json['user_id'] == userId);
      if (mine.isEmpty) return null;
      return BusinessModel.fromJson(mine.first);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al cargar tu negocio: $e');
    }
  }

  @override
  Future<BusinessModel> updateBusiness(String id, BusinessModel business) async {
    try {
      await _client.put('/businesses/$id', body: business.toRequestJson());
      return business;
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al actualizar tu negocio: $e');
    }
  }
}
