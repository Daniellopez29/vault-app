import '../../../core/error.dart';
import 'fixtures.dart';
import 'models.dart';

abstract class MarketplaceRemoteDataSource {
  Future<List<MarketplaceItemModel>> getItems();
  Future<List<PromoBannerModel>> getPromoBanners();
}

class MarketplaceRemoteDataSourceImpl implements MarketplaceRemoteDataSource {
  @override
  Future<List<MarketplaceItemModel>> getItems() async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return List.of(MarketplaceFixtures.mockItems);
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