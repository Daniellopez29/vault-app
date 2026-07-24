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

final uploadBusinessPhotoUseCaseProvider = Provider<UploadBusinessPhotoUseCase>((ref) {
  return UploadBusinessPhotoUseCase(ref.read(businessRepositoryProvider));
});

final deleteBusinessPhotoUseCaseProvider = Provider<DeleteBusinessPhotoUseCase>((ref) {
  return DeleteBusinessPhotoUseCase(ref.read(businessRepositoryProvider));
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
  final UploadBusinessPhotoUseCase _uploadPhoto;
  final DeleteBusinessPhotoUseCase _deletePhoto;

  BusinessController(
    this._getMyBusiness,
    this._updateBusiness,
    this._uploadPhoto,
    this._deletePhoto,
  ) : super(const BusinessState()) {
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

  /// Edita los datos completos del negocio (nombre, categorías, descripción,
  /// ubicación, especialidades).
  Future<bool> update({
    required String name,
    required List<String> types,
    required String description,
    required String location,
    required List<String> specialties,
  }) async {
    final current = state.business;
    if (current == null) return false;

    final result = await _updateBusiness(current.copyWith(
      name: name,
      types: types,
      description: description,
      location: location,
      specialties: specialties,
    ));
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

  Future<bool> uploadPhoto({required List<int> bytes, required String filename}) async {
    final current = state.business;
    if (current == null) return false;

    final result = await _uploadPhoto(UploadBusinessPhotoParams(
      businessId: current.id,
      bytes: bytes,
      filename: filename,
    ));
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

  Future<bool> deletePhoto(String photoId) async {
    final current = state.business;
    if (current == null) return false;

    final result = await _deletePhoto(DeleteBusinessPhotoParams(
      businessId: current.id,
      photoId: photoId,
    ));
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
    ref.read(uploadBusinessPhotoUseCaseProvider),
    ref.read(deleteBusinessPhotoUseCaseProvider),
  );
});

// ─── Directorio público de negocios (Shop) ───

final getAllBusinessesUseCaseProvider = Provider<GetAllBusinessesUseCase>((ref) {
  return GetAllBusinessesUseCase(ref.read(businessRepositoryProvider));
});

/// Todos los negocios registrados, para el directorio del Shop.
/// Es una carga simple de solo lectura, por eso un FutureProvider en vez de
/// un StateNotifier: la UI lo consume con .when(loading/error/data).
final allBusinessesProvider = FutureProvider<List<BusinessEntity>>((ref) async {
  final result = await ref.read(getAllBusinessesUseCaseProvider)(const NoParams());
  return result.fold(
    (failure) => throw Exception(failure.message),
    (businesses) => businesses,
  );
});
