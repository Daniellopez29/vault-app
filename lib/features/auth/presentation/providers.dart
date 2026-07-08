import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/enums.dart';
import '../data/datasources.dart';
import '../data/repositories.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';
import '../domain/usecases.dart';

enum AuthStatus { initial, loading, authenticated, roleSelection, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(remoteDataSource: AuthRemoteDataSourceImpl());
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.read(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.read(authRepositoryProvider));
});

final loginWithGoogleUseCaseProvider = Provider<LoginWithGoogleUseCase>((ref) {
  return LoginWithGoogleUseCase(ref.read(authRepositoryProvider));
});

final saveUserRoleUseCaseProvider = Provider<SaveUserRoleUseCase>((ref) {
  return SaveUserRoleUseCase(ref.read(authRepositoryProvider));
});

final deleteAccountUseCaseProvider = Provider<DeleteAccountUseCase>((ref) {
  return DeleteAccountUseCase(ref.read(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.read(authRepositoryProvider));
});

final updateDisplayNameUseCaseProvider = Provider<UpdateDisplayNameUseCase>((ref) {
  return UpdateDisplayNameUseCase(ref.read(authRepositoryProvider));
});

final updatePasswordUseCaseProvider = Provider<UpdatePasswordUseCase>((ref) {
  return UpdatePasswordUseCase(ref.read(authRepositoryProvider));
});

final authControllerProvider =
StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    loginUseCase: ref.read(loginUseCaseProvider),
    registerUseCase: ref.read(registerUseCaseProvider),
    loginWithGoogleUseCase: ref.read(loginWithGoogleUseCaseProvider),
    saveUserRoleUseCase: ref.read(saveUserRoleUseCaseProvider),
    deleteAccountUseCase: ref.read(deleteAccountUseCaseProvider),
    updateDisplayNameUseCase: ref.read(updateDisplayNameUseCaseProvider),
    updatePasswordUseCase: ref.read(updatePasswordUseCaseProvider),
    logoutUseCase: ref.read(logoutUseCaseProvider),
  );
});

class AuthController extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LoginWithGoogleUseCase _loginWithGoogleUseCase;
  final SaveUserRoleUseCase _saveUserRoleUseCase;
  final DeleteAccountUseCase _deleteAccountUseCase;
  final UpdateDisplayNameUseCase _updateDisplayNameUseCase;
  final UpdatePasswordUseCase _updatePasswordUseCase;
  final LogoutUseCase _logoutUseCase;

  AuthController({
    required this._loginUseCase,
    required this._registerUseCase,
    required this._loginWithGoogleUseCase,
    required this._saveUserRoleUseCase,
    required this._deleteAccountUseCase,
    required this._updateDisplayNameUseCase,
    required this._updatePasswordUseCase,
    required this._logoutUseCase,
  }) : super(const AuthState());

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    final result =
    await _loginUseCase(LoginParams(email: email, password: password));
    result.fold(
          (failure) => state = state.copyWith(
          status: AuthStatus.error, errorMessage: failure.message),
          (user) => state = state.copyWith(
          status: AuthStatus.authenticated, user: user),
    );
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? phone,
    String? businessName,
    String? specialty,
    String? location,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    final result = await _registerUseCase(
      RegisterParams(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
        phone: phone,
        businessName: businessName,
        specialty: specialty,
        location: location,
      ),
    );
    result.fold(
          (failure) => state = state.copyWith(
          status: AuthStatus.error, errorMessage: failure.message),
          (user) => state = state.copyWith(
          status: AuthStatus.authenticated, user: user),
    );
  }

  Future<void> loginWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    final result = await _loginWithGoogleUseCase();
    result.fold(
          (failure) => state = state.copyWith(
          status: AuthStatus.error, errorMessage: failure.message),
          (user) => state = state.copyWith(
          status: AuthStatus.roleSelection, user: user),
    );
  }

  Future<void> saveRole(UserRole role) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    final result = await _saveUserRoleUseCase(role);
    result.fold(
          (failure) => state = state.copyWith(
          status: AuthStatus.error, errorMessage: failure.message),
          (user) => state = state.copyWith(
          status: AuthStatus.authenticated, user: user),
    );
  }

  Future<void> logout() async {
    await _logoutUseCase();
    state = const AuthState();
  }

  Future<bool> deleteAccount() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    final result = await _deleteAccountUseCase();
    return result.fold(
          (failure) {
        state = state.copyWith(
            status: AuthStatus.error, errorMessage: failure.message);
        return false;
      },
          (_) {
        state = const AuthState();
        return true;
      },
    );
  }

  Future<bool> updateDisplayName(String fullName) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    final result = await _updateDisplayNameUseCase(fullName);
    return result.fold(
          (failure) {
        state = state.copyWith(
            status: AuthStatus.error, errorMessage: failure.message);
        return false;
      },
          (user) {
        state = state.copyWith(
            status: AuthStatus.authenticated, user: user);
        return true;
      },
    );
  }

  Future<bool> updatePassword(String newPassword) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    final result = await _updatePasswordUseCase(newPassword);
    return result.fold(
          (failure) {
        state = state.copyWith(
            status: AuthStatus.error, errorMessage: failure.message);
        return false;
      },
          (_) {
        state = state.copyWith(status: AuthStatus.authenticated);
        return true;
      },
    );
  }
}