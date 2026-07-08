import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/enums.dart';
import '../../../core/error.dart';
import 'models.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? phone,
    String? businessName,
    String? specialty,
    String? location,
  });
  Future<UserModel> loginWithGoogle();
  Future<UserModel> saveUserRole(UserRole role);
  Future<UserModel> getCurrentUser();
  Future<void> deleteAccount();
  Future<UserModel> updateDisplayName(String fullName);
  Future<void> updatePassword(String newPassword);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// La clave del rol se compone con el UID para que cada cuenta conserve
  /// su propio rol en el dispositivo. Con una clave global, el rol de la
  /// última cuenta que iniciaba sesión sobrescribía al de las demás
  /// (un Coleccionista entraba como Restaurador, por ejemplo).
  String _roleKey(String uid) => 'user_role_$uid';

  Future<UserRole> _getSavedRole(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_roleKey(uid));
    return UserRole.fromValue(value ?? 'general');
  }

  Future<void> _saveRole(String uid, UserRole role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey(uid), role.value);
  }

  UserModel _buildModel(User user, UserRole role) {
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      fullName: user.displayName,
      role: role,
    );
  }

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user!;
      final role = await _getSavedRole(user.uid);
      return _buildModel(user, role);
    } on FirebaseAuthException catch (e) {
      throw ServerFailure(_mapError(e.code));
    }
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? phone,
    String? businessName,
    String? specialty,
    String? location,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user!.updateDisplayName(fullName);
      await credential.user!.reload();
      final user = _auth.currentUser!;

      // Guarda el rol ELEGIDO en el registro (ya no un rol fijo).
      await _saveRole(user.uid, role);

      // NOTA: phone, businessName, specialty y location se reciben ya,
      // pero su persistencia llega con Supabase. Aquí solo se captura el flujo;
      // cuando exista el backend, se escriben en la tabla de perfiles.

      return _buildModel(user, role);
    } on FirebaseAuthException catch (e) {
      throw ServerFailure(_mapError(e.code));
    }
  }

  @override
  Future<UserModel> loginWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) throw ServerFailure('Inicio de sesión cancelado.');
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      final user = _auth.currentUser!;
      final role = await _getSavedRole(user.uid);
      return _buildModel(user, role);
    } on FirebaseAuthException catch (e) {
      throw ServerFailure(_mapError(e.code));
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure('Error al iniciar sesión con Google.');
    }
  }

  @override
  Future<UserModel> saveUserRole(UserRole role) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw ServerFailure('No hay sesión activa.');
      await _saveRole(user.uid, role);
      return _buildModel(user, role);
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure('Error al guardar el rol.');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw ServerFailure('No hay sesión activa.');
      final role = await _getSavedRole(user.uid);
      return _buildModel(user, role);
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure('Error al obtener el usuario.');
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw ServerFailure('No hay sesión activa.');
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw ServerFailure(_mapError(e.code));
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure('Error al eliminar la cuenta.');
    }
  }

  @override
  Future<UserModel> updateDisplayName(String fullName) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw ServerFailure('No hay sesión activa.');
      await user.updateDisplayName(fullName);
      await user.reload();
      final refreshed = _auth.currentUser!;
      final role = await _getSavedRole(refreshed.uid);
      return _buildModel(refreshed, role);
    } on FirebaseAuthException catch (e) {
      throw ServerFailure(_mapError(e.code));
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure('Error al actualizar el nombre.');
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw ServerFailure('No hay sesión activa.');
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw ServerFailure(
            'Por seguridad, cierra sesión y vuelve a iniciar antes de cambiar tu contraseña.');
      }
      throw ServerFailure(_mapError(e.code));
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure('Error al actualizar la contraseña.');
    }
  }

  String _mapError(String code) {
    switch (code) {
      case 'user-not-found':       return 'No existe una cuenta con ese correo.';
      case 'wrong-password':       return 'Contraseña incorrecta.';
      case 'invalid-email':        return 'El correo no es válido.';
      case 'user-disabled':        return 'Esta cuenta ha sido deshabilitada.';
      case 'invalid-credential':   return 'Correo o contraseña incorrectos.';
      case 'email-already-in-use': return 'Ya existe una cuenta con ese correo.';
      case 'weak-password':        return 'La contraseña es muy débil.';
      default:                     return 'Error inesperado. Intenta de nuevo.';
    }
  }
}