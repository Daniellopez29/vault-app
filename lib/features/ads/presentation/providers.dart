import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../data/datasources.dart';
import '../data/repositories.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';
import '../domain/usecases.dart';

final adRemoteDataSourceProvider = Provider<AdRemoteDataSource>((ref) {
  return AdRemoteDataSourceImpl(ref.read(apiClientProvider));
});

final adRepositoryProvider = Provider<AdRepository>((ref) {
  return AdRepositoryImpl(remote: ref.read(adRemoteDataSourceProvider));
});

final getActiveAdsUseCaseProvider =
    Provider((ref) => GetActiveAdsUseCase(ref.read(adRepositoryProvider)));

final createAdUseCaseProvider =
    Provider((ref) => CreateAdUseCase(ref.read(adRepositoryProvider)));

final deleteAdUseCaseProvider =
    Provider((ref) => DeleteAdUseCase(ref.read(adRepositoryProvider)));

enum ActiveAdsStatus { loading, loaded, error }

class ActiveAdsState {
  final ActiveAdsStatus status;
  final List<AdEntity> ads;
  final String? errorMessage;

  const ActiveAdsState({
    this.status = ActiveAdsStatus.loading,
    this.ads = const [],
    this.errorMessage,
  });

  ActiveAdsState copyWith({
    ActiveAdsStatus? status,
    List<AdEntity>? ads,
    String? errorMessage,
  }) {
    return ActiveAdsState(
      status: status ?? this.status,
      ads: ads ?? this.ads,
      errorMessage: errorMessage,
    );
  }
}

/// Anuncios activos de una sección (`.family` por sección). Alimenta el
/// carrusel y el grid intercalado del Shop (sección "marketplace").
class ActiveAdsController extends StateNotifier<ActiveAdsState> {
  final GetActiveAdsUseCase _getActiveAds;
  final String section;

  ActiveAdsController(this._getActiveAds, this.section) : super(const ActiveAdsState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(status: ActiveAdsStatus.loading);
    final result = await _getActiveAds(section);
    result.fold(
      (failure) => state = state.copyWith(
        status: ActiveAdsStatus.error,
        errorMessage: failure.message,
      ),
      (ads) => state = state.copyWith(status: ActiveAdsStatus.loaded, ads: ads),
    );
  }
}

final activeAdsControllerProvider =
    StateNotifierProvider.family<ActiveAdsController, ActiveAdsState, String>((ref, section) {
  return ActiveAdsController(ref.read(getActiveAdsUseCaseProvider), section);
});
