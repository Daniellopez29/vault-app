import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/usecase.dart';
import '../../profile/domain/entities.dart';
import '../../profile/presentation/providers.dart';
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
  final List<PromoBannerEntity> banners;
  final String? errorMessage;

  const ShopState({
    this.status = ShopStatus.initial,
    this.items = const [],
    this.banners = const [],
    this.errorMessage,
  });

  ShopState copyWith({
    ShopStatus? status,
    List<MarketplaceItemEntity>? items,
    List<PromoBannerEntity>? banners,
    String? errorMessage,
  }) {
    return ShopState(
      status: status ?? this.status,
      items: items ?? this.items,
      banners: banners ?? this.banners,
      errorMessage: errorMessage,
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
          items: _combinedItems(),
          banners: banners,
        );
      },
    );
  }

  /// Recombina activos en venta + mock, sin volver a pedir el mock
  /// (se llama cuando el usuario pone/quita algo de venta).
  void refreshForSale() {
    if (state.status != ShopStatus.loaded) return;
    state = state.copyWith(items: _combinedItems());
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