import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import '../../../core/usecase.dart';
import 'entities.dart';
import 'repositories.dart';

/// Obtiene los planes de un tipo de suscripción (producto o negocio).
/// Sigue el mismo contrato UseCase que el resto de la app.
class GetSubscriptionPlansUseCase
    implements UseCase<List<SubscriptionPlan>, SubscriptionType> {
  final SubscriptionRepository repository;

  GetSubscriptionPlansUseCase(this.repository);

  @override
  Future<Either<Failure, List<SubscriptionPlan>>> call(SubscriptionType type) {
    return repository.getPlans(type);
  }
}
