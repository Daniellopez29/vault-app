import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/usecase.dart';
import '../data/datasources.dart';
import '../data/repositories.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';
import '../domain/usecases.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(
      remoteDataSource: ProfileRemoteDataSourceImpl());
});

final getUserAssetsUseCaseProvider = Provider<GetUserAssetsUseCase>((ref) {
  return GetUserAssetsUseCase(ref.read(profileRepositoryProvider));
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

// ─── ASSETS STATE ─────────────────────────────────────────────────────────────

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

  Map<String, int> get categoryCounts {
    final counts = <String, int>{};
    for (final asset in assets) {
      counts[asset.brand] = (counts[asset.brand] ?? 0) + 1;
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
    deleteAssetUseCase: ref.read(deleteAssetUseCaseProvider),
  );
});

class ProfileAssetsController extends StateNotifier<ProfileAssetsState> {
  final GetUserAssetsUseCase _getUserAssets;
  final DeleteAssetUseCase _deleteAsset;

  ProfileAssetsController({
    required GetUserAssetsUseCase getUserAssetsUseCase,
    required DeleteAssetUseCase deleteAssetUseCase,
  })  : _getUserAssets = getUserAssetsUseCase,
        _deleteAsset = deleteAssetUseCase,
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

  Future<void> deleteAsset(String assetId) async {
    final result = await _deleteAsset(assetId);
    result.fold(
          (failure) => state = state.copyWith(errorMessage: failure.message),
          (_) => loadAssets(),
    );
  }
}

// ─── RESTORER PROFILE STATE ───────────────────────────────────────────────────

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
    required GetRestorerProfileUseCase getRestorerProfile,
    required SaveRestorerProfileUseCase saveRestorerProfile,
    required String userId,
  })  : _getRestorerProfile = getRestorerProfile,
        _saveRestorerProfile = saveRestorerProfile,
        _userId = userId,
        super(const RestorerProfileState()) {
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
}