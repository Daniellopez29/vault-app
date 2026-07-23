import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/usecase.dart';
import '../../auth/presentation/providers.dart';
import '../data/datasources.dart';
import '../data/repositories.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';
import '../domain/usecases.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    remoteDataSource: ProfileRemoteDataSourceImpl(
      ref.read(apiClientProvider),
      currentUserId: () => ref.read(authControllerProvider).user?.id,
    ),
  );
});

final getUserAssetsUseCaseProvider = Provider<GetUserAssetsUseCase>((ref) {
  return GetUserAssetsUseCase(ref.read(profileRepositoryProvider));
});

final addAssetUseCaseProvider = Provider<AddAssetUseCase>((ref) {
  return AddAssetUseCase(ref.read(profileRepositoryProvider));
});

final deleteAssetUseCaseProvider = Provider<DeleteAssetUseCase>((ref) {
  return DeleteAssetUseCase(ref.read(profileRepositoryProvider));
});

final getRestorerProfileUseCaseProvider =
Provider<GetRestorerProfileUseCase>((ref) {
  return GetRestorerProfileUseCase(ref.read(profileRepositoryProvider));
});

final saveRestorerProfileUseCaseProvider =
Provider<SaveRestorerProfileUseCase>((ref) {
  return SaveRestorerProfileUseCase(ref.read(profileRepositoryProvider));
});

final setAssetForSaleUseCaseProvider = Provider<SetAssetForSaleUseCase>((ref) {
  return SetAssetForSaleUseCase(ref.read(profileRepositoryProvider));
});

final setAssetPublishedUseCaseProvider =
Provider<SetAssetPublishedUseCase>((ref) {
  return SetAssetPublishedUseCase(ref.read(profileRepositoryProvider));
});

final registerBusinessUseCaseProvider = Provider<RegisterBusinessUseCase>((ref) {
  return RegisterBusinessUseCase(ref.read(profileRepositoryProvider));
});

// â”€â”€â”€ ASSETS STATE â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

  /// Conteo de activos por categorÃ­a (para el header del Perfil).
  Map<String, int> get categoryCounts {
    final counts = <String, int>{};
    for (final asset in assets) {
      final key = asset.category.displayName;
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return counts;
  }

  double get totalValue =>
      assets.fold(0, (sum, a) => sum + a.originalPrice);

  int get totalArticles => assets.length;
}

final profileAssetsControllerProvider =
StateNotifierProvider<ProfileAssetsController, ProfileAssetsState>((ref) {
  return ProfileAssetsController(
    getUserAssetsUseCase: ref.read(getUserAssetsUseCaseProvider),
    addAssetUseCase: ref.read(addAssetUseCaseProvider),
    deleteAssetUseCase: ref.read(deleteAssetUseCaseProvider),
    setAssetForSaleUseCase: ref.read(setAssetForSaleUseCaseProvider),
    setAssetPublishedUseCase: ref.read(setAssetPublishedUseCaseProvider),
  );
});

class ProfileAssetsController extends StateNotifier<ProfileAssetsState> {
  final GetUserAssetsUseCase _getUserAssets;
  final AddAssetUseCase _addAsset;
  final DeleteAssetUseCase _deleteAsset;
  final SetAssetForSaleUseCase _setForSale;
  final SetAssetPublishedUseCase _setPublished;

  ProfileAssetsController({
    required GetUserAssetsUseCase getUserAssetsUseCase,
    required AddAssetUseCase addAssetUseCase,
    required DeleteAssetUseCase deleteAssetUseCase,
    required SetAssetForSaleUseCase setAssetForSaleUseCase,
    required SetAssetPublishedUseCase setAssetPublishedUseCase,
  })  : _getUserAssets = getUserAssetsUseCase,
        _addAsset = addAssetUseCase,
        _deleteAsset = deleteAssetUseCase,
        _setForSale = setAssetForSaleUseCase,
        _setPublished = setAssetPublishedUseCase,
        super(const ProfileAssetsState()) {
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

  /// Registra un activo nuevo y refresca el grid con la lista actualizada.
  Future<bool> addAsset(AssetEntity asset) async {
    final result = await _addAsset(asset);
    return result.fold(
          (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
          (_) {
        loadAssets();
        return true;
      },
    );
  }

  Future<void> deleteAsset(String assetId) async {
    final result = await _deleteAsset(assetId);
    result.fold(
          (failure) => state = state.copyWith(errorMessage: failure.message),
          (_) => loadAssets(),
    );
  }

  /// Pone o quita un activo de venta. ActualizaciÃ³n optimista: el cambio
  /// se refleja en pantalla al instante, y si falla, recarga el estado real.
  Future<void> setForSale(
      AssetEntity asset, {
        required bool forSale,
        double? price,
        String? description,
      }) async {
    _patchAsset(asset.copyWith(
      isForSale: forSale,
      salePrice: forSale ? price : null,
      saleDescription: forSale ? description : null,
    ));

    final result = await _setForSale(SetForSaleParams(
      asset: asset,
      forSale: forSale,
      price: price,
      description: description,
    ));
    result.fold((failure) {
      state = state.copyWith(errorMessage: failure.message);
      loadAssets();
    }, (_) {});
  }

  /// Publica o despublica un activo en el Feed (actualizaciÃ³n optimista).
  Future<void> setPublished(
      AssetEntity asset, {
        required bool published,
        String? caption,
      }) async {
    _patchAsset(asset.copyWith(
      isPublished: published,
      publishCaption: published ? caption : null,
    ));

    final result = await _setPublished(
      SetPublishedParams(asset: asset, published: published, caption: caption),
    );
    result.fold((failure) {
      state = state.copyWith(errorMessage: failure.message);
      loadAssets();
    }, (_) {});
  }

  /// Reemplaza un activo en la lista por su versiÃ³n actualizada, en un solo lugar.
  void _patchAsset(AssetEntity updated) {
    final assets = [
      for (final a in state.assets) a.id == updated.id ? updated : a,
    ];
    state = state.copyWith(assets: assets);
  }
}

// â”€â”€â”€ RESTORER PROFILE STATE â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

enum RestorerProfileStatus { initial, loading, loaded, empty, error }

class RestorerProfileState {
  final RestorerProfileStatus status;
  final RestorerProfileEntity? profile;
  final String? errorMessage;

  const RestorerProfileState({
    this.status = RestorerProfileStatus.initial,
    this.profile,
    this.errorMessage,
  });

  RestorerProfileState copyWith({
    RestorerProfileStatus? status,
    RestorerProfileEntity? profile,
    String? errorMessage,
  }) {
    return RestorerProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
    );
  }
}

final restorerProfileControllerProvider =
StateNotifierProvider.family<RestorerProfileController,
    RestorerProfileState, String>((ref, userId) {
  return RestorerProfileController(
    getRestorerProfile: ref.read(getRestorerProfileUseCaseProvider),
    saveRestorerProfile: ref.read(saveRestorerProfileUseCaseProvider),
    userId: userId,
  );
});

class RestorerProfileController
    extends StateNotifier<RestorerProfileState> {
  final GetRestorerProfileUseCase _getRestorerProfile;
  final SaveRestorerProfileUseCase _saveRestorerProfile;
  final String _userId;

  RestorerProfileController({
    required this._getRestorerProfile,
    required this._saveRestorerProfile,
    required this._userId,
  })  : super(const RestorerProfileState()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = state.copyWith(status: RestorerProfileStatus.loading);
    final result = await _getRestorerProfile(_userId);
    result.fold(
          (failure) => state = state.copyWith(
          status: RestorerProfileStatus.error,
          errorMessage: failure.message),
          (profile) => state = state.copyWith(
          status: profile == null
              ? RestorerProfileStatus.empty
              : RestorerProfileStatus.loaded,
          profile: profile),
    );
  }

  Future<void> saveProfile(RestorerProfileEntity profile) async {
    final result = await _saveRestorerProfile(profile);
    result.fold(
          (failure) => state = state.copyWith(errorMessage: failure.message),
          (_) => loadProfile(),
    );
  }

  /// Agrega un servicio al perfil. Si el usuario aun no tiene perfil de
  /// especialista, se crea uno al vuelo con este primer servicio.
  ///
  /// El backend guarda el perfil completo (no servicios sueltos), por eso
  /// se reconstruye entero preservando los demas campos.
  Future<void> addService(RestorerServiceEntity service) async {
    final current = state.profile;
    await saveProfile(RestorerProfileEntity(
      userId: _userId,
      bio: current?.bio ?? '',
      specialties: current?.specialties ?? const [],
      services: [...?current?.services, service],
      rating: current?.rating ?? 0,
      reviewsCount: current?.reviewsCount ?? 0,
    ));
  }

  /// Reemplaza un servicio existente conservando su id.
  Future<void> updateService(RestorerServiceEntity service) async {
    final current = state.profile;
    if (current == null) return;
    await saveProfile(RestorerProfileEntity(
      userId: _userId,
      bio: current.bio,
      specialties: current.specialties,
      services: current.services
          .map((s) => s.id == service.id ? service : s)
          .toList(),
      rating: current.rating,
      reviewsCount: current.reviewsCount,
    ));
  }

  /// Quita un servicio por id y guarda el perfil actualizado.
  Future<void> removeService(String serviceId) async {
    final current = state.profile;
    if (current == null) return;
    await saveProfile(RestorerProfileEntity(
      userId: _userId,
      bio: current.bio,
      specialties: current.specialties,
      services: current.services.where((s) => s.id != serviceId).toList(),
      rating: current.rating,
      reviewsCount: current.reviewsCount,
    ));
  }
}





// ─── Directorio publico de servicios ───

final getAllRestorerProfilesUseCaseProvider =
    Provider<GetAllRestorerProfilesUseCase>((ref) {
  return GetAllRestorerProfilesUseCase(ref.read(profileRepositoryProvider));
});

/// Todos los especialistas con servicios publicados, para que cualquiera
/// pueda buscar quien ofrece que.
final allRestorerProfilesProvider =
    FutureProvider<List<RestorerProfileEntity>>((ref) async {
  final result = await ref.read(getAllRestorerProfilesUseCaseProvider)();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (profiles) => profiles,
  );
});
