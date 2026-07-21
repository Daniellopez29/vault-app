import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';
import 'datasources.dart';

/// Implementación del repositorio. Envuelve el datasource en Either/Failure,
/// igual que el resto de la app. Si el datasource falla, devuelve ServerFailure.
class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionDataSource dataSource;

  SubscriptionRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, List<SubscriptionPlan>>> getPlans(
    SubscriptionType type,
  ) async {
    try {
      final plans = await dataSource.getPlans(type);
      return Right(plans);
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}
