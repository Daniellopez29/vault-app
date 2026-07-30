import 'package:dartz/dartz.dart';

import '../../../core/error.dart';
import 'entities.dart';

abstract class ServiceRequestsRepository {
  Future<Either<Failure, ServiceRequestEntity>> create({
    required String assetId,
    required String businessId,
    required String type,
  });

  /// Solicitudes que mandé como dueño de un activo -- para "Mis Activos".
  Future<Either<Failure, List<ServiceRequestEntity>>> getMine();

  /// Solicitudes que le llegaron a mi negocio -- para "Mis Negocios".
  Future<Either<Failure, List<ServiceRequestEntity>>> getIncoming();

  Future<Either<Failure, ServiceRequestEntity>> accept(String id);
  Future<Either<Failure, ServiceRequestEntity>> start(String id);
  Future<Either<Failure, ServiceRequestEntity>> finish(String id);
  Future<Either<Failure, ServiceRequestEntity>> confirm(String id);
}
