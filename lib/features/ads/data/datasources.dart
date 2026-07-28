import '../../../core/api_client.dart';
import '../../../core/error.dart';
import 'models.dart';

abstract class AdRemoteDataSource {
  Future<List<AdModel>> getActiveAds(String section);

  Future<AdModel> createAd({
    required String title,
    required String description,
    required String imageUrl,
    required String targetSection,
    required String targetId,
  });

  Future<void> deleteAd(String id);
}

/// `payment/` (Stripe: suscripciones, ads, órdenes) -- mismo servicio y
/// mismo host que `SubscriptionRemoteDataSource`, ruteado por el gateway
/// bajo `/api/v1/ads`.
class AdRemoteDataSourceImpl implements AdRemoteDataSource {
  final ApiClient _client;

  AdRemoteDataSourceImpl(this._client);

  @override
  Future<List<AdModel>> getActiveAds(String section) async {
    try {
      // Pública (ver ads/infrastructure/router/router.go) -- cualquier
      // usuario, con o sin sesión, puede listar los anuncios activos.
      final body =
          await _client.get('/ads', query: {'section': section}, auth: false);
      // El backend envuelve en {"ads": [...]} (ver ListActiveAdsController.go).
      final list = (body as Map<String, dynamic>)['ads'] as List<dynamic>? ?? const [];
      return list.map((e) => AdModel.fromJson(e as Map<String, dynamic>)).toList();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al cargar los anuncios: $e');
    }
  }

  @override
  Future<AdModel> createAd({
    required String title,
    required String description,
    required String imageUrl,
    required String targetSection,
    required String targetId,
  }) async {
    try {
      final body = await _client.post('/ads', body: {
        'title': title,
        'description': description,
        'image_url': imageUrl,
        'target_section': targetSection,
        'target_id': targetId,
      });
      return AdModel.fromJson(body as Map<String, dynamic>);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al crear el anuncio: $e');
    }
  }

  @override
  Future<void> deleteAd(String id) async {
    try {
      await _client.delete('/ads/$id');
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al eliminar el anuncio: $e');
    }
  }
}
