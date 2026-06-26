import '../domain/entities.dart';

/// Por ahora es igual a UserEntity. En el Paso 3 (Firebase) le agregamos
/// un factory `fromFirebaseUser` para construirlo desde el User de FirebaseAuth.
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.fullName,
  });
}