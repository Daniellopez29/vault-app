import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import 'entities.dart';

/// Contrato de acceso a los planes de suscripción. La implementación real
/// (mock hoy, backend después) vive en la capa data. Solo esa capa cambia
/// cuando se conecte FastAPI/Supabase.
abstract class SubscriptionRepository {
  Future<Either<Failure, List<SubscriptionPlan>>> getPlans(
    SubscriptionType type,
  );
}
