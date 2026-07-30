import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/datasources.dart';
import '../data/repositories.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';
import '../domain/usecases.dart';

final serviceRequestsRepositoryProvider = Provider<ServiceRequestsRepository>((ref) {
  return ServiceRequestsRepositoryImpl(
    remote: ServiceRequestsRemoteDataSourceImpl(ref.read(apiClientProvider)),
  );
});

final createServiceRequestUseCaseProvider = Provider<CreateServiceRequestUseCase>((ref) {
  return CreateServiceRequestUseCase(ref.read(serviceRequestsRepositoryProvider));
});

final getMyServiceRequestsUseCaseProvider = Provider<GetMyServiceRequestsUseCase>((ref) {
  return GetMyServiceRequestsUseCase(ref.read(serviceRequestsRepositoryProvider));
});

final getIncomingServiceRequestsUseCaseProvider = Provider<GetIncomingServiceRequestsUseCase>((ref) {
  return GetIncomingServiceRequestsUseCase(ref.read(serviceRequestsRepositoryProvider));
});

final acceptServiceRequestUseCaseProvider = Provider<AcceptServiceRequestUseCase>((ref) {
  return AcceptServiceRequestUseCase(ref.read(serviceRequestsRepositoryProvider));
});

final startServiceRequestUseCaseProvider = Provider<StartServiceRequestUseCase>((ref) {
  return StartServiceRequestUseCase(ref.read(serviceRequestsRepositoryProvider));
});

final finishServiceRequestUseCaseProvider = Provider<FinishServiceRequestUseCase>((ref) {
  return FinishServiceRequestUseCase(ref.read(serviceRequestsRepositoryProvider));
});

final confirmServiceRequestUseCaseProvider = Provider<ConfirmServiceRequestUseCase>((ref) {
  return ConfirmServiceRequestUseCase(ref.read(serviceRequestsRepositoryProvider));
});

enum ServiceRequestsStatus { initial, loading, loaded, error }

class ServiceRequestsState {
  final ServiceRequestsStatus status;
  final List<ServiceRequestEntity> requests;
  final String? errorMessage;

  const ServiceRequestsState({
    this.status = ServiceRequestsStatus.initial,
    this.requests = const [],
    this.errorMessage,
  });

  ServiceRequestsState copyWith({
    ServiceRequestsStatus? status,
    List<ServiceRequestEntity>? requests,
    String? errorMessage,
  }) {
    return ServiceRequestsState(
      status: status ?? this.status,
      requests: requests ?? this.requests,
      errorMessage: errorMessage,
    );
  }
}

/// "Mis Activos" -- solicitudes que el usuario mandó como dueño, para saber
/// cuáles están en curso o listas para confirmar recepción.
final myServiceRequestsControllerProvider =
    StateNotifierProvider<MyServiceRequestsController, ServiceRequestsState>((ref) {
  return MyServiceRequestsController(
    getMine: ref.read(getMyServiceRequestsUseCaseProvider),
    confirmUseCase: ref.read(confirmServiceRequestUseCaseProvider),
  );
});

class MyServiceRequestsController extends StateNotifier<ServiceRequestsState> {
  final GetMyServiceRequestsUseCase _getMine;
  final ConfirmServiceRequestUseCase _confirm;

  MyServiceRequestsController({
    required GetMyServiceRequestsUseCase getMine,
    required ConfirmServiceRequestUseCase confirmUseCase,
  })  : _getMine = getMine,
        _confirm = confirmUseCase,
        super(const ServiceRequestsState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(status: ServiceRequestsStatus.loading);
    final result = await _getMine();
    result.fold(
      (failure) => state = state.copyWith(status: ServiceRequestsStatus.error, errorMessage: failure.message),
      (requests) => state = state.copyWith(status: ServiceRequestsStatus.loaded, requests: requests),
    );
  }

  Future<bool> confirm(String id) async {
    final result = await _confirm(id);
    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (_) {
        load();
        return true;
      },
    );
  }
}

/// "Mis Negocios" -- artículos que le llegaron al negocio del usuario.
final incomingServiceRequestsControllerProvider =
    StateNotifierProvider<IncomingServiceRequestsController, ServiceRequestsState>((ref) {
  return IncomingServiceRequestsController(
    getIncoming: ref.read(getIncomingServiceRequestsUseCaseProvider),
    acceptUseCase: ref.read(acceptServiceRequestUseCaseProvider),
    startUseCase: ref.read(startServiceRequestUseCaseProvider),
    finishUseCase: ref.read(finishServiceRequestUseCaseProvider),
  );
});

class IncomingServiceRequestsController extends StateNotifier<ServiceRequestsState> {
  final GetIncomingServiceRequestsUseCase _getIncoming;
  final AcceptServiceRequestUseCase _accept;
  final StartServiceRequestUseCase _start;
  final FinishServiceRequestUseCase _finish;

  IncomingServiceRequestsController({
    required GetIncomingServiceRequestsUseCase getIncoming,
    required AcceptServiceRequestUseCase acceptUseCase,
    required StartServiceRequestUseCase startUseCase,
    required FinishServiceRequestUseCase finishUseCase,
  })  : _getIncoming = getIncoming,
        _accept = acceptUseCase,
        _start = startUseCase,
        _finish = finishUseCase,
        super(const ServiceRequestsState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(status: ServiceRequestsStatus.loading);
    final result = await _getIncoming();
    result.fold(
      (failure) => state = state.copyWith(status: ServiceRequestsStatus.error, errorMessage: failure.message),
      (requests) => state = state.copyWith(status: ServiceRequestsStatus.loaded, requests: requests),
    );
  }

  Future<bool> accept(String id) async {
    final result = await _accept(id);
    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (_) {
        load();
        return true;
      },
    );
  }

  Future<bool> start(String id) async {
    final result = await _start(id);
    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (_) {
        load();
        return true;
      },
    );
  }

  Future<bool> finish(String id) async {
    final result = await _finish(id);
    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (_) {
        load();
        return true;
      },
    );
  }
}
