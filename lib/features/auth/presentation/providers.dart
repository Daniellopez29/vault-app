import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources.dart';
import '../data/repositories.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';
import '../domain/usecases.dart';

enum AuthStatus { initial, loading, authenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({AuthStatus? status, UserEntity? user, String? errorMessage}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
}

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepositoryImpl(
  remoteDataSource: AuthRemoteDataSourceImpl(),
));

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.read(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.read(authRepositoryProvider));
});

final loginWithGoogleUseCaseProvider = Provider<LoginWithGoogleUseCase>((ref) {
  return LoginWithGoogleUseCase(ref.read(authRepositoryProvider));
});

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    ref.read(loginUseCaseProvider),
    ref.read(registerUseCaseProvider),
    ref.read(loginWithGoogleUseCaseProvider),
  );
});

class AuthController extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LoginWithGoogleUseCase _loginWithGoogleUseCase;

  AuthController(this._loginUseCase, this._registerUseCase, this._loginWithGoogleUseCase)
      : super(const AuthState());

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    final result = await _loginUseCase(LoginParams(email: email, password: password));
    result.fold(
          (failure) => state = state.copyWith(status: AuthStatus.error, errorMessage: failure.message),
          (user) => state = state.copyWith(status: AuthStatus.authenticated, user: user),
    );
  }

  Future<void> register({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    final result = await _registerUseCase(RegisterParams(email: email, password: password));
    result.fold(
          (failure) => state = state.copyWith(status: AuthStatus.error, errorMessage: failure.message),
          (user) => state = state.copyWith(status: AuthStatus.authenticated, user: user),
    );
  }

  Future<void> loginWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    final result = await _loginWithGoogleUseCase();
    result.fold(
          (failure) => state = state.copyWith(status: AuthStatus.error, errorMessage: failure.message),
          (user) => state = state.copyWith(status: AuthStatus.authenticated, user: user),
    );
  }

  Future<void> logout() async {
    state = const AuthState();
  }
}