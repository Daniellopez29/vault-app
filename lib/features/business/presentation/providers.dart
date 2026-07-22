import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/usecase.dart';
import '../../auth/presentation/providers.dart';
import '../data/datasources.dart';
import '../data/repositories.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';
import '../domain/usecases.dart';

final businessRepositoryProvider = Provider<BusinessRepository>((ref) {
  return BusinessRepositoryImpl(
    remoteDataSource: BusinessRemoteDataSourceImpl(
      ref.read(apiClientProvider),
      currentUserId: () => ref.read(authControllerProvider).user?.id,
    ),
  );
});

final getMyBusinessUseCaseProvider = Provider<GetMyBusinessUseCase>((ref) {
  return GetMyBusinessUseCase(ref.read(businessRepositoryProvider));
});

final updateBusinessUseCaseProvider = Provider<UpdateBusinessUseCase>((ref) {
  return UpdateBusinessUseCase(ref.read(businessRepositoryProvider));
});

enum BusinessStatus { loading, loaded, error }

class BusinessState {
  final BusinessStatus status;
  final BusinessEntity? business;
  final String? errorMessage;

  const BusinessState({
    this.status = BusinessStatus.loading,
    this.business,
    this.errorMessage,
  });

  BusinessState copyWith({
    BusinessStatus? status,
    BusinessEntity? business,
    bool clearBusiness = false,
    String? errorMessage,
  }) {
    return BusinessState(
      status: status ?? this.status,
      business: clearBusiness ? null : (business ?? this.business),
      errorMessage: errorMessage,
    );
  }
}

class BusinessController extends StateNotifier<BusinessState> {
  final GetMyBusinessUseCase _getMyBusiness;
  final UpdateBusinessUseCase _updateBusiness;

  BusinessController(this._getMyBusiness, this._updateBusiness) : super(const BusinessState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(status: BusinessStatus.loading);
    final result = await _getMyBusiness(const NoParams());
    result.fold(
      (failure) => state = state.copyWith(
        status: BusinessStatus.error,
        errorMessage: failure.message,
      ),
      (business) => state = BusinessState(status: BusinessStatus.loaded, business: business),
    );
  }

  Future<bool> updateLocation(String location) async {
    final current = state.business;
    if (current == null) return false;

    final result = await _updateBusiness(current.copyWith(location: location));
    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (updated) {
        state = state.copyWith(status: BusinessStatus.loaded, business: updated);
        return true;
      },
    );
  }
}

final businessControllerProvider =
    StateNotifierProvider<BusinessController, BusinessState>((ref) {
  return BusinessController(
    ref.read(getMyBusinessUseCaseProvider),
    ref.read(updateBusinessUseCaseProvider),
  );
});
