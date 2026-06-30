import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/error.dart';

abstract class AuthRemoteDataSource {
  Future<void> login(String email, String password);
  Future<void> register(String email, String password, String fullName);
  Future<void> loginWithGoogle();
  String? getCurrentDisplayName();
  String? getCurrentEmail();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw ServerFailure(_mapError(e.code));
    }
  }

  @override
  Future<void> register(String email, String password, String fullName) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(fullName);
      await credential.user?.reload();
    } on FirebaseAuthException catch (e) {
      throw ServerFailure(_mapError(e.code));
    }
  }

  @override
  Future<void> loginWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) throw ServerFailure('Inicio de sesión cancelado.');
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw ServerFailure(_mapError(e.code));
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure('Error al iniciar sesión con Google.');
    }
  }

  @override
  String? getCurrentDisplayName() => _auth.currentUser?.displayName;

  @override
  String? getCurrentEmail() => _auth.currentUser?.email;

  String _mapError(String code) {
    switch (code) {
      case 'user-not-found':     return 'No existe una cuenta con ese correo.';
      case 'wrong-password':     return 'Contraseña incorrecta.';
      case 'invalid-email':      return 'El correo no es válido.';
      case 'user-disabled':      return 'Esta cuenta ha sido deshabilitada.';
      case 'invalid-credential': return 'Correo o contraseña incorrectos.';
      case 'email-already-in-use': return 'Ya existe una cuenta con ese correo.';
      case 'weak-password':      return 'La contraseña es muy débil.';
      default:                   return 'Error inesperado. Intenta de nuevo.';
    }
  }
}