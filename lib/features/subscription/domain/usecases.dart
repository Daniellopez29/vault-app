import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
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

class CreateSubscriptionParams extends Equatable {
  final String planId;
  final String email;
  final String paymentMethodId;

  const CreateSubscriptionParams({
    required this.planId,
    required this.email,
    required this.paymentMethodId,
  });

  @override
  List<Object?> get props => [planId, email, paymentMethodId];
}

/// Contrata un plan con un PaymentMethod ya creado del lado del cliente.
class CreateSubscriptionUseCase
    implements UseCase<SubscriptionStatus, CreateSubscriptionParams> {
  final SubscriptionRepository repository;

  CreateSubscriptionUseCase(this.repository);

  @override
  Future<Either<Failure, SubscriptionStatus>> call(
    CreateSubscriptionParams params,
  ) {
    return repository.createSubscription(
      planId: params.planId,
      email: params.email,
      paymentMethodId: params.paymentMethodId,
    );
  }
}

class GetSubscriptionStatusUseCase {
  final SubscriptionRepository repository;
  const GetSubscriptionStatusUseCase(this.repository);

  Future<Either<Failure, SubscriptionStatus?>> call() => repository.getStatus();
}

class CancelSubscriptionUseCase {
  final SubscriptionRepository repository;
  const CancelSubscriptionUseCase(this.repository);

  Future<Either<Failure, void>> call() => repository.cancel();
}
