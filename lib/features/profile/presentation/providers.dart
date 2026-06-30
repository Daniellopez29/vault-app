import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/usecase.dart';
import '../data/datasources.dart';
import '../data/repositories.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';
import '../domain/usecases.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(remoteDataSource: ProfileRemoteDataSourceImpl());
});

final getUserAssetsUseCaseProvider = Provider<GetUserAssetsUseCase>((ref) {
  return GetUserAssetsUseCase(ref.read(profileRepositoryProvider));
});

final deleteAssetUseCaseProvider = Provider<DeleteAssetUseCase>((ref) {
  return DeleteAssetUseCase(ref.read(profileRepositoryProvider));
});

enum ProfileAssetsStatus { initial, loading, loaded, error }

class ProfileAssetsState {
  final ProfileAssetsStatus status;
  final List<AssetEntity> assets;
  final String? errorMessage;

  const ProfileAssetsState({
    this.status = ProfileAssetsStatus.initial,
    this.assets = const [],
    this.errorMessage,
  });

  ProfileAssetsState copyWith({
    ProfileAssetsStatus? status,
    List<AssetEntity>? assets,
    String? errorMessage,
  }) {
    return ProfileAssetsState(
      status: status ?? this.status,
      assets: assets ?? this.assets,
      errorMessage: errorMessage,
    );
  }

  /// Conteo de artículos por marca/categoría, calculado en tiempo real
  /// a partir de los assets reales (no datos quemados).
  Map<String, int> get categoryCounts {
    final counts = <String, int>{};
    for (final asset in assets) {
      counts[asset.brand] = (counts[asset.brand] ?? 0) + 1;
    }
    return counts;
  }

  int get totalArticles => assets.length;
}

final profileAssetsControllerProvider =
StateNotifierProvider<ProfileAssetsController, ProfileAssetsState>((ref) {
  return ProfileAssetsController(
    ref.read(getUserAssetsUseCaseProvider),
    ref.read(deleteAssetUseCaseProvider),
  );
});

class ProfileAssetsController extends StateNotifier<ProfileAssetsState> {
  final GetUserAssetsUseCase _getUserAssets;
  final DeleteAssetUseCase _deleteAsset;

  ProfileAssetsController(this._getUserAssets, this._deleteAsset)
      : super(const ProfileAssetsState()) {
    loadAssets();
  }

  Future<void> loadAssets() async {
    state = state.copyWith(status: ProfileAssetsStatus.loading);
    final result = await _getUserAssets(const NoParams());
    result.fold(
          (failure) => state = state.copyWith(
          status: ProfileAssetsStatus.error, errorMessage: failure.message),
          (assets) => state = state.copyWith(
          status: ProfileAssetsStatus.loaded, assets: assets),
    );
  }

  Future<void> deleteAsset(String assetId) async {
    final result = await _deleteAsset(assetId);
    result.fold(
          (failure) => state = state.copyWith(errorMessage: failure.message),
          (_) => loadAssets(),
    );
  }
}