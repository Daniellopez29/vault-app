import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/usecase.dart';
import '../../profile/domain/entities.dart';
import '../../profile/presentation/providers.dart';
import '../../subscription/domain/entities.dart';
import '../data/datasources.dart';
import '../data/repositories.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';
import '../domain/usecases.dart';

final marketplaceRepositoryProvider = Provider<MarketplaceRepository>((ref) {
  return MarketplaceRepositoryImpl(
    remoteDataSource: MarketplaceRemoteDataSourceImpl(),
  );
});

final getMarketplaceItemsUseCaseProvider =
Provider<GetMarketplaceItemsUseCase>((ref) {
  return GetMarketplaceItemsUseCase(ref.read(marketplaceRepositoryProvider));
});

final getPromoBannersUseCaseProvider = Provider<GetPromoBannersUseCase>((ref) {
  return GetPromoBannersUseCase(ref.read(marketplaceRepositoryProvider));
});

enum ShopStatus { initial, loading, loaded, error }

class ShopState {
  final ShopStatus status;
  final List<MarketplaceItemEntity> items;
  final List<CarouselSlide> slides;
  final String? errorMessage;
  final String searchQuery;

  const ShopState({
    this.status = ShopStatus.initial,
    this.items = const [],
    this.slides = const [],
    this.errorMessage,
    this.searchQuery = '',
  });

  ShopState copyWith({
    ShopStatus? status,
    List<MarketplaceItemEntity>? items,
    List<CarouselSlide>? slides,
    String? errorMessage,
    String? searchQuery,
  }) {
    return ShopState(
      status: status ?? this.status,
      items: items ?? this.items,
      slides: slides ?? this.slides,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

final shopControllerProvider =
StateNotifierProvider<ShopController, ShopState>((ref) {
  final controller = ShopController(
    ref.read(getMarketplaceItemsUseCaseProvider),
    ref.read(getPromoBannersUseCaseProvider),
    ref,
  );
  // Cuando cambian los activos en venta del inventario, el Shop se recombina.
  ref.listen(profileAssetsControllerProvider, (previous, next) {
    controller.refreshForSale();
  });
  return controller;
});

class ShopController extends StateNotifier<ShopState> {
  final GetMarketplaceItemsUseCase _getItems;
  final GetPromoBannersUseCase _getBanners;
  final Ref _ref;

  // Catálogo mock cacheado, para no volver a pedirlo al recombinar.
  List<MarketplaceItemEntity> _mockItems = const [];

  ShopController(this._getItems, this._getBanners, this._ref)
      : super(const ShopState()) {
    loadShop();
  }

  Future<void> loadShop() async {
    state = state.copyWith(status: ShopStatus.loading);

    final bannersResult = await _getBanners(const NoParams());
    final itemsResult = await _getItems(const NoParams());

    itemsResult.fold(
          (failure) => state = state.copyWith(
        status: ShopStatus.error,
        errorMessage: failure.message,
      ),
          (items) {
        _mockItems = items;
        final banners = bannersResult.fold(
              (_) => <PromoBannerEntity>[],
              (list) => list,
        );
        state = state.copyWith(
          status: ShopStatus.loaded,
          items: _visibleItems(),
          slides: _buildSlides(banners),
        );
      },
    );
  }

  /// Arma los slides del carrusel: primero el anuncio de suscripción de
  /// productos (CTA fijo de la app), luego las promos que vengan del backend.
  /// El anuncio no depende del backend: aunque no haya banners, sigue estando.
  List<CarouselSlide> _buildSlides(List<PromoBannerEntity> banners) {
    return [
      const SubscriptionSlide(SubscriptionType.product),
      ...banners.map(PromoSlide.new),
    ];
  }

  /// Recombina activos en venta + mock, sin volver a pedir el mock
  /// (se llama cuando el usuario pone/quita algo de venta).
  void refreshForSale() {
    if (state.status != ShopStatus.loaded) return;
    state = state.copyWith(items: _visibleItems());
  }

  /// Actualiza el texto de búsqueda y recalcula los productos visibles.
  /// Filtrado 100% local sobre la lista ya cargada; cuando exista backend,
  /// solo cambia el datasource, no esta lógica de presentación.
  void search(String query) {
    state = state.copyWith(
      searchQuery: query,
      items: _visibleItems(query: query),
    );
  }

  /// Limpia la búsqueda y muestra el catálogo completo de nuevo.
  void clearSearch() => search('');

  /// Lista final que ve la UI: combina tus activos en venta + el mock,
  /// y aplica el filtro de búsqueda por título o marca.
  List<MarketplaceItemEntity> _visibleItems({String? query}) {
    final effectiveQuery = (query ?? state.searchQuery).trim().toLowerCase();
    final combined = _combinedItems();

    if (effectiveQuery.isEmpty) return combined;

    return combined.where((item) {
      final title = item.title.toLowerCase();
      final brand = item.brand.toLowerCase();
      return title.contains(effectiveQuery) || brand.contains(effectiveQuery);
    }).toList();
  }

  /// Tus activos en venta primero, luego el catálogo mock.
  List<MarketplaceItemEntity> _combinedItems() {
    final forSale = _ref
        .read(profileAssetsControllerProvider)
        .assets
        .where((asset) => asset.isForSale)
        .map(_assetToItem)
        .toList();
    return [...forSale, ..._mockItems];
  }

  /// Convierte un activo del inventario en un producto del Shop.
  MarketplaceItemEntity _assetToItem(AssetEntity asset) {
    return MarketplaceItemEntity(
      id: asset.id,
      brand: asset.brand,
      title: asset.name,
      imageUrl: asset.imageUrl,
      origin: asset.origin,
      size: asset.size,
      price: asset.salePrice ?? 0,
      rating: 0,
      isVerified: asset.isVerified,
    );
  }
}
