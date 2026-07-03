import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/enums.dart';
import '../../../core/error.dart';
import 'models.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String email, String password, String fullName);
  Future<UserModel> loginWithGoogle();
  Future<UserModel> saveUserRole(UserRole role);
  Future<UserModel> getCurrentUser();
  Future<void> deleteAccount();
  Future<UserModel> updateDisplayName(String fullName);
  Future<void> updatePassword(String newPassword);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const _keyRole = 'user_role';

  Future<UserRole> _getSavedRole() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_keyRole);
    return UserRole.fromValue(value ?? 'general');
  }

  Future<void> _saveRole(UserRole role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRole, role.value);
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
      final role = await _getSavedRole();
      return _buildModel(credential.user!, role);
    } on FirebaseAuthException catch (e) {
      throw ServerFailure(_mapError(e.code));
    }
  }

  @override
  Future<UserModel> register(
      String email, String password, String fullName) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user!.updateDisplayName(fullName);
      await credential.user!.reload();
      await _saveRole(UserRole.general);
      return _buildModel(_auth.currentUser!, UserRole.general);
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
      final role = await _getSavedRole();
      return _buildModel(_auth.currentUser!, role);
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
      await _saveRole(role);
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
      final role = await _getSavedRole();
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
      final role = await _getSavedRole();
      return _buildModel(_auth.currentUser!, role);
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