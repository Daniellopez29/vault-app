import 'package:dartz/dartz.dart';

import '../../../core/error.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';
import 'datasources.dart';

class ServiceRequestsRepositoryImpl implements ServiceRequestsRepository {
  final ServiceRequestsRemoteDataSource _remote;

  ServiceRequestsRepositoryImpl({required ServiceRequestsRemoteDataSource remote}) : _remote = remote;

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action, String fallbackMessage) async {
    try {
      return Right(await action());
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('$fallbackMessage: $e'));
    }
  }

  @override
  Future<Either<Failure, ServiceRequestEntity>> create({
    required String assetId,
    required String businessId,
    required String type,
  }) =>
      _guard(
        () => _remote.create(assetId: assetId, businessId: businessId, type: type),
        'Error al mandar el artículo a servicio',
      );

  @override
  Future<Either<Failure, List<ServiceRequestEntity>>> getMine() =>
      _guard(() => _remote.getMine(), 'Error al cargar tus solicitudes de servicio');

  @override
  Future<Either<Failure, List<ServiceRequestEntity>>> getIncoming() =>
      _guard(() => _remote.getIncoming(), 'Error al cargar los artículos recibidos');

  @override
  Future<Either<Failure, ServiceRequestEntity>> accept(String id) =>
      _guard(() => _remote.accept(id), 'Error al aceptar la solicitud');

  @override
  Future<Either<Failure, ServiceRequestEntity>> start(String id) =>
      _guard(() => _remote.start(id), 'Error al iniciar el servicio');

  @override
  Future<Either<Failure, ServiceRequestEntity>> finish(String id) =>
      _guard(() => _remote.finish(id), 'Error al marcar como terminado');

  @override
  Future<Either<Failure, ServiceRequestEntity>> confirm(String id) =>
      _guard(() => _remote.confirm(id), 'Error al confirmar la recepción');
}
