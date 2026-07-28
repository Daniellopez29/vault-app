import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import 'entities.dart';

abstract class ConnectRepository {
  Future<Either<Failure, ConnectStatusEntity>> getStatus();

  /// Genera el link de onboarding de Stripe (hosted, se abre en el
  /// navegador del sistema) para [email]. [refreshUrl]/[returnUrl] son
  /// obligatorios para Stripe pero no necesitan tener contenido real del
  /// lado de la app -- el usuario vuelve a mano y refresca el estado.
  Future<Either<Failure, String>> createOnboardingLink({
    required String email,
    required String refreshUrl,
    required String returnUrl,
  });
}
