import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../data/datasources.dart';
import '../data/repositories.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';
import '../domain/usecases.dart';

final connectRemoteDataSourceProvider = Provider<ConnectRemoteDataSource>((ref) {
  return ConnectRemoteDataSourceImpl(ref.read(apiClientProvider));
});

final connectRepositoryProvider = Provider<ConnectRepository>((ref) {
  return ConnectRepositoryImpl(remote: ref.read(connectRemoteDataSourceProvider));
});

final getConnectStatusUseCaseProvider =
    Provider((ref) => GetConnectStatusUseCase(ref.read(connectRepositoryProvider)));

final createOnboardingLinkUseCaseProvider =
    Provider((ref) => CreateOnboardingLinkUseCase(ref.read(connectRepositoryProvider)));

enum ConnectStatusLoad { loading, loaded, error }

class ConnectStatusState {
  final ConnectStatusLoad status;
  final ConnectStatusEntity account;
  final String? errorMessage;

  const ConnectStatusState({
    this.status = ConnectStatusLoad.loading,
    this.account = const ConnectStatusEntity(chargesEnabled: false),
    this.errorMessage,
  });

  ConnectStatusState copyWith({
    ConnectStatusLoad? status,
    ConnectStatusEntity? account,
    String? errorMessage,
  }) {
    return ConnectStatusState(
      status: status ?? this.status,
      account: account ?? this.account,
      errorMessage: errorMessage,
    );
  }
}

class ConnectStatusController extends StateNotifier<ConnectStatusState> {
  final GetConnectStatusUseCase _getStatus;

  ConnectStatusController(this._getStatus) : super(const ConnectStatusState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(status: ConnectStatusLoad.loading);
    final result = await _getStatus();
    result.fold(
      (failure) => state = state.copyWith(
        status: ConnectStatusLoad.error,
        errorMessage: failure.message,
      ),
      (account) => state = ConnectStatusState(
        status: ConnectStatusLoad.loaded,
        account: account,
      ),
    );
  }
}

final connectStatusControllerProvider =
    StateNotifierProvider<ConnectStatusController, ConnectStatusState>((ref) {
  return ConnectStatusController(ref.read(getConnectStatusUseCaseProvider));
});
