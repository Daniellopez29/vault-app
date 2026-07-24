import '../../../core/api_client.dart';
import '../../../core/error.dart';
import 'models.dart';

abstract class BusinessRemoteDataSource {
  Future<BusinessModel?> getMyBusiness();
  Future<BusinessModel> updateBusiness(String id, BusinessModel business);
  Future<List<BusinessModel>> getAllBusinesses();
  Future<BusinessModel> uploadPhoto(String id, {required List<int> bytes, required String filename});
  Future<BusinessModel> deletePhoto(String id, String photoId);
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

  /// Mismo endpoint que getMyBusiness, pero sin filtrar por usuario: es el
  /// directorio público de negocios que ve cualquiera en el Shop.
  @override
  Future<List<BusinessModel>> getAllBusinesses() async {
    try {
      final body = await _client.get('/businesses', auth: false);
      final list = body as List<dynamic>? ?? const [];
      return list
          .map((e) => BusinessModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al cargar los negocios: $e');
    }
  }

  @override
  Future<BusinessModel> uploadPhoto(String id, {required List<int> bytes, required String filename}) async {
    try {
      final body = await _client.postMultipart(
        '/businesses/$id/photos',
        bytes: bytes,
        filename: filename,
        fieldName: 'image',
      );
      return BusinessModel.fromJson(body as Map<String, dynamic>);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al subir la foto: $e');
    }
  }

  @override
  Future<BusinessModel> deletePhoto(String id, String photoId) async {
    try {
      final body = await _client.delete('/businesses/$id/photos/$photoId');
      return BusinessModel.fromJson(body as Map<String, dynamic>);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al eliminar la foto: $e');
    }
  }
}
