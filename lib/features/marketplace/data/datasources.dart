import '../../../core/api_client.dart';
import '../../../core/error.dart';
import 'fixtures.dart';
import 'models.dart';

abstract class MarketplaceRemoteDataSource {
  Future<List<MarketplaceItemModel>> getItems();
  Future<List<PromoBannerModel>> getPromoBanners();
}

class MarketplaceRemoteDataSourceImpl implements MarketplaceRemoteDataSource {
  final ApiClient _client;

  MarketplaceRemoteDataSourceImpl(this._client);

  /// GET /assets es público y devuelve los de TODOS los usuarios -- el
  /// catálogo del Shop es justamente eso filtrado por is_for_sale, sin
  /// importar quién lo publicó (a diferencia de "mis activos" en Perfil,
  /// que sí filtra por user_id).
  @override
  Future<List<MarketplaceItemModel>> getItems() async {
    try {
      final body = await _client.get('/assets', auth: false);
      final list = body as List<dynamic>? ?? const [];
      return list
          .map((e) => e as Map<String, dynamic>)
          .where((json) => json['is_for_sale'] == true)
          .map(MarketplaceItemModel.fromJson)
          .toList();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al cargar el marketplace: $e');
    }
  }

  @override
  Future<List<PromoBannerModel>> getPromoBanners() async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return List.of(MarketplaceFixtures.mockBanners);
    } catch (e) {
      throw ServerFailure('Error al cargar las promociones: $e');
    }
  }
}