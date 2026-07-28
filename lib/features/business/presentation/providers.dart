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

// ─── Catálogo de servicios de un negocio ───

final getBusinessServicesUseCaseProvider = Provider<GetBusinessServicesUseCase>((ref) {
  return GetBusinessServicesUseCase(ref.read(businessRepositoryProvider));
});

final createBusinessServiceUseCaseProvider = Provider<CreateBusinessServiceUseCase>((ref) {
  return CreateBusinessServiceUseCase(ref.read(businessRepositoryProvider));
});

final updateBusinessServiceUseCaseProvider = Provider<UpdateBusinessServiceUseCase>((ref) {
  return UpdateBusinessServiceUseCase(ref.read(businessRepositoryProvider));
});

final deleteBusinessServiceUseCaseProvider = Provider<DeleteBusinessServiceUseCase>((ref) {
  return DeleteBusinessServiceUseCase(ref.read(businessRepositoryProvider));
});

enum BusinessServicesStatus { loading, loaded, error }

class BusinessServicesState {
  final BusinessServicesStatus status;
  final List<BusinessServiceEntity> services;
  final String? errorMessage;

  const BusinessServicesState({
    this.status = BusinessServicesStatus.loading,
    this.services = const [],
    this.errorMessage,
  });

  BusinessServicesState copyWith({
    BusinessServicesStatus? status,
    List<BusinessServiceEntity>? services,
    String? errorMessage,
  }) {
    return BusinessServicesState(
      status: status ?? this.status,
      services: services ?? this.services,
      errorMessage: errorMessage,
    );
  }
}

/// Catálogo de servicios de un negocio (`.family` por business id) --
/// pública para verla (directorio de especialistas), CRUD solo para el
/// dueño (el backend valida ownership, ver ErrNotOwner en Go).
class BusinessServicesController extends StateNotifier<BusinessServicesState> {
  final GetBusinessServicesUseCase _getServices;
  final CreateBusinessServiceUseCase _createService;
  final UpdateBusinessServiceUseCase _updateService;
  final DeleteBusinessServiceUseCase _deleteService;
  final String businessId;

  BusinessServicesController(
    this._getServices,
    this._createService,
    this._updateService,
    this._deleteService,
    this.businessId,
  ) : super(const BusinessServicesState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(status: BusinessServicesStatus.loading);
    final result = await _getServices(businessId);
    result.fold(
      (failure) => state = state.copyWith(
        status: BusinessServicesStatus.error,
        errorMessage: failure.message,
      ),
      (services) => state = state.copyWith(
        status: BusinessServicesStatus.loaded,
        services: services,
      ),
    );
  }

  Future<bool> addService({
    required String title,
    required String description,
    required double price,
  }) async {
    final result = await _createService(BusinessServiceParams(
      businessId: businessId,
      title: title,
      description: description,
      price: price,
    ));
    return result.fold((failure) {
      state = state.copyWith(errorMessage: failure.message);
      return false;
    }, (_) {
      load();
      return true;
    });
  }

  Future<bool> updateService(
    String serviceId, {
    required String title,
    required String description,
    required double price,
  }) async {
    final result = await _updateService(BusinessServiceParams(
      businessId: businessId,
      serviceId: serviceId,
      title: title,
      description: description,
      price: price,
    ));
    return result.fold((failure) {
      state = state.copyWith(errorMessage: failure.message);
      return false;
    }, (_) {
      load();
      return true;
    });
  }

  Future<bool> removeService(String serviceId) async {
    final result = await _deleteService(
      DeleteBusinessServiceParams(businessId: businessId, serviceId: serviceId),
    );
    return result.fold((failure) {
      state = state.copyWith(errorMessage: failure.message);
      return false;
    }, (_) {
      state = state.copyWith(services: state.services.where((s) => s.id != serviceId).toList());
      return true;
    });
  }
}

final businessServicesControllerProvider = StateNotifierProvider.family<
    BusinessServicesController, BusinessServicesState, String>((ref, businessId) {
  return BusinessServicesController(
    ref.read(getBusinessServicesUseCaseProvider),
    ref.read(createBusinessServiceUseCaseProvider),
    ref.read(updateBusinessServiceUseCaseProvider),
    ref.read(deleteBusinessServiceUseCaseProvider),
    businessId,
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
