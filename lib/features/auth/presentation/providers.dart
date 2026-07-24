import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/enums.dart';
import '../../../core/providers.dart';
import '../../addresses/presentation/providers.dart' show addressesControllerProvider;
import '../../business/presentation/providers.dart'
    show businessControllerProvider, allBusinessesProvider;
import '../../cart/presentation/providers.dart' show cartControllerProvider;
import '../../chat/presentation/providers.dart' show conversationsControllerProvider;
import '../../favorites/presentation/providers.dart' show favoritesControllerProvider;
import '../../home/presentation/providers.dart' show feedControllerProvider;
import '../../notifications/presentation/providers.dart' show notificationsControllerProvider;
import '../../profile/presentation/providers.dart'
    show profileAssetsControllerProvider, restorerProfileControllerProvider;
import '../data/datasources.dart';
import '../data/repositories.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';
import '../domain/usecases.dart';

/// Tiempo de inactividad tras el cual se cierra la sesión automáticamente.
/// El timer solo corre mientras hay un usuario autenticado y se reinicia
/// con cada interacción (ver [AuthController.onUserInteraction]).
const kInactivityTimeout = Duration(minutes: 5);

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
  return AuthRepositoryImpl(
    remoteDataSource: AuthRemoteDataSourceImpl(ref.read(apiClientProvider)),
  );
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

final updateRoleUseCaseProvider = Provider<UpdateRoleUseCase>((ref) {
  return UpdateRoleUseCase(ref.read(authRepositoryProvider));
});

final addRolesUseCaseProvider = Provider<AddRolesUseCase>((ref) {
  return AddRolesUseCase(ref.read(authRepositoryProvider));
});

final uploadProfilePhotoUseCaseProvider = Provider<UploadProfilePhotoUseCase>((ref) {
  return UploadProfilePhotoUseCase(ref.read(authRepositoryProvider));
});

final authControllerProvider =
StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    ref: ref,
    loginUseCase: ref.read(loginUseCaseProvider),
    registerUseCase: ref.read(registerUseCaseProvider),
    loginWithGoogleUseCase: ref.read(loginWithGoogleUseCaseProvider),
    saveUserRoleUseCase: ref.read(saveUserRoleUseCaseProvider),
    deleteAccountUseCase: ref.read(deleteAccountUseCaseProvider),
    updateDisplayNameUseCase: ref.read(updateDisplayNameUseCaseProvider),
    updatePasswordUseCase: ref.read(updatePasswordUseCaseProvider),
    updateRoleUseCase: ref.read(updateRoleUseCaseProvider),
    addRolesUseCase: ref.read(addRolesUseCaseProvider),
    uploadProfilePhotoUseCase: ref.read(uploadProfilePhotoUseCaseProvider),
    logoutUseCase: ref.read(logoutUseCaseProvider),
  );
});

class AuthController extends StateNotifier<AuthState> {
  final Ref _ref;
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LoginWithGoogleUseCase _loginWithGoogleUseCase;
  final SaveUserRoleUseCase _saveUserRoleUseCase;
  final DeleteAccountUseCase _deleteAccountUseCase;
  final UpdateDisplayNameUseCase _updateDisplayNameUseCase;
  final UpdatePasswordUseCase _updatePasswordUseCase;
  final UpdateRoleUseCase _updateRoleUseCase;
  final AddRolesUseCase _addRolesUseCase;
  final UploadProfilePhotoUseCase _uploadProfilePhotoUseCase;
  final LogoutUseCase _logoutUseCase;

  Timer? _inactivityTimer;

  AuthController({
    required Ref ref,
    required this._loginUseCase,
    required this._registerUseCase,
    required this._loginWithGoogleUseCase,
    required this._saveUserRoleUseCase,
    required this._deleteAccountUseCase,
    required this._updateDisplayNameUseCase,
    required this._updatePasswordUseCase,
    required this._updateRoleUseCase,
    required this._addRolesUseCase,
    required this._uploadProfilePhotoUseCase,
    required this._logoutUseCase,
  })  : _ref = ref,
        super(const AuthState());

  /// Todo el estado que se cargó "por usuario" (guardados, mis artículos,
  /// mi negocio, carrito, direcciones, notificaciones, feed) vive en
  /// providers globales que solo cargan una vez -- sin esto, al cerrar
  /// sesión e iniciar con otra cuenta, la UI seguía mostrando los datos
  /// de la cuenta anterior hasta reiniciar la app.
  void _invalidateUserScopedProviders() {
    _ref.invalidate(favoritesControllerProvider);
    _ref.invalidate(profileAssetsControllerProvider);
    _ref.invalidate(restorerProfileControllerProvider);
    _ref.invalidate(businessControllerProvider);
    _ref.invalidate(allBusinessesProvider);
    _ref.invalidate(cartControllerProvider);
    _ref.invalidate(addressesControllerProvider);
    _ref.invalidate(notificationsControllerProvider);
    _ref.invalidate(feedControllerProvider);
    _ref.invalidate(conversationsControllerProvider);
  }

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
    _cancelInactivityTimer();
    await _logoutUseCase();
    state = const AuthState();
    _invalidateUserScopedProviders();
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
        _cancelInactivityTimer();
        state = const AuthState();
        _invalidateUserScopedProviders();
        return true;
      },
    );
  }

  // ── Cierre de sesión por inactividad ──────────────────────────────────────

  /// Se debe llamar en cada interacción del usuario (tap, scroll, etc.)
  /// mientras la app está en uso. Reinicia la cuenta regresiva de
  /// [kInactivityTimeout]; si se agota sin nueva interacción, cierra sesión.
  void onUserInteraction() {
    if (state.status != AuthStatus.authenticated) return;
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(kInactivityTimeout, logout);
  }

  void _cancelInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
  }

  @override
  void dispose() {
    _cancelInactivityTimer();
    super.dispose();
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

  /// Sube al backend y actualiza la foto de perfil. No cambia [status] a
  /// loading -- se llama desde el header del Perfil, un spinner de página
  /// completa se vería mal ahí; el llamador maneja su propio estado visual.
  Future<bool> uploadProfilePhoto({required List<int> bytes, required String filename}) async {
    final result = await _uploadProfilePhotoUseCase(
      UploadProfilePhotoParams(bytes: bytes, filename: filename),
    );
    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (user) {
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
        return true;
      },
    );
  }


  /// Cambia el rol del usuario. Solo se llama cuando
  /// el usuario eligió explícitamente (p.ej. al registrar un negocio con
  /// una categoría específica), no como efecto secundario.
  Future<bool> updateRole(UserRole role) async {
    final result = await _updateRoleUseCase(role);
    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (user) {
        state = state.copyWith(user: user);
        return true;
      },
    );
  }

  /// Agrega roles al histórico acumulado de la cuenta (no reemplaza los que
  /// ya tenía) -- se llama al completar una acción que otorga uno o más
  /// roles nuevos, como registrar un negocio con varias categorías.
  Future<bool> addRoles(List<UserRole> roles) async {
    final result = await _addRolesUseCase(roles);
    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (user) {
        state = state.copyWith(user: user);
        return true;
      },
    );
  }
}

