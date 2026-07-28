import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/usecase.dart';
import '../../profile/presentation/providers.dart';
import '../../subscription/domain/entities.dart';
import '../data/datasources.dart';
import '../data/repositories.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';
import '../domain/usecases.dart';

final marketplaceRepositoryProvider = Provider<MarketplaceRepository>((ref) {
  return MarketplaceRepositoryImpl(
    remoteDataSource: MarketplaceRemoteDataSourceImpl(ref.read(apiClientProvider)),
  );
});

final getMarketplaceItemsUseCaseProvider =
Provider<GetMarketplaceItemsUseCase>((ref) {
  return GetMarketplaceItemsUseCase(ref.read(marketplaceRepositoryProvider));
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
  final controller = ShopController(ref.read(getMarketplaceItemsUseCaseProvider));
  // Cuando el usuario pone/quita uno de sus activos en venta, el backend ya
  // lo refleja en GET /assets -- basta con recargar el Shop desde cero.
  ref.listen(profileAssetsControllerProvider, (previous, next) {
    controller.loadShop();
  });
  return controller;
});

class ShopController extends StateNotifier<ShopState> {
  final GetMarketplaceItemsUseCase _getItems;

  // Catálogo cacheado, para no volver a pedirlo al filtrar por búsqueda.
  List<MarketplaceItemEntity> _items = const [];

  ShopController(this._getItems) : super(const ShopState()) {
    loadShop();
  }

  Future<void> loadShop() async {
    state = state.copyWith(status: ShopStatus.loading);

    final itemsResult = await _getItems(const NoParams());

    itemsResult.fold(
          (failure) => state = state.copyWith(
        status: ShopStatus.error,
        errorMessage: failure.message,
      ),
          (items) {
        _items = items;
        state = state.copyWith(
          status: ShopStatus.loaded,
          items: _visibleItems(),
          slides: _buildSlides(),
        );
      },
    );
  }

  /// Slides fijos del carrusel que no dependen de anuncios reales (el CTA de
  /// suscripción). Los anuncios activos se agregan aparte en `shop_tab.dart`
  /// (ver `activeAdsControllerProvider`), para que se actualicen solos en
  /// cuanto alguien publica/cancela uno, sin recargar todo el Shop.
  List<CarouselSlide> _buildSlides() {
    return [
      const SubscriptionSlide(SubscriptionType.product),
    ];
  }

  /// Actualiza el texto de búsqueda y recalcula los productos visibles.
  /// Filtrado 100% local sobre la lista ya cargada.
  void search(String query) {
    state = state.copyWith(
      searchQuery: query,
      items: _visibleItems(query: query),
    );
  }

  /// Limpia la búsqueda y muestra el catálogo completo de nuevo.
  void clearSearch() => search('');

  /// Lista final que ve la UI: aplica el filtro de búsqueda por título o marca.
  List<MarketplaceItemEntity> _visibleItems({String? query}) {
    final effectiveQuery = (query ?? state.searchQuery).trim().toLowerCase();
    if (effectiveQuery.isEmpty) return _items;

    return _items.where((item) {
      final title = item.title.toLowerCase();
      final brand = item.brand.toLowerCase();
      return title.contains(effectiveQuery) || brand.contains(effectiveQuery);
    }).toList();
  }
}
