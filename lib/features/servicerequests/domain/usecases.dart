import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error.dart';
import 'entities.dart';
import 'repositories.dart';

class CreateServiceRequestParams extends Equatable {
  final String assetId;
  final String businessId;
  final String type;

  const CreateServiceRequestParams({
    required this.assetId,
    required this.businessId,
    required this.type,
  });

  @override
  List<Object?> get props => [assetId, businessId, type];
}

class CreateServiceRequestUseCase {
  final ServiceRequestsRepository repository;
  const CreateServiceRequestUseCase(this.repository);

  Future<Either<Failure, ServiceRequestEntity>> call(CreateServiceRequestParams params) =>
      repository.create(assetId: params.assetId, businessId: params.businessId, type: params.type);
}

class GetMyServiceRequestsUseCase {
  final ServiceRequestsRepository repository;
  const GetMyServiceRequestsUseCase(this.repository);

  Future<Either<Failure, List<ServiceRequestEntity>>> call() => repository.getMine();
}

class GetIncomingServiceRequestsUseCase {
  final ServiceRequestsRepository repository;
  const GetIncomingServiceRequestsUseCase(this.repository);

  Future<Either<Failure, List<ServiceRequestEntity>>> call() => repository.getIncoming();
}

class AcceptServiceRequestUseCase {
  final ServiceRequestsRepository repository;
  const AcceptServiceRequestUseCase(this.repository);

  Future<Either<Failure, ServiceRequestEntity>> call(String id) => repository.accept(id);
}

class StartServiceRequestUseCase {
  final ServiceRequestsRepository repository;
  const StartServiceRequestUseCase(this.repository);

  Future<Either<Failure, ServiceRequestEntity>> call(String id) => repository.start(id);
}

class FinishServiceRequestUseCase {
  final ServiceRequestsRepository repository;
  const FinishServiceRequestUseCase(this.repository);

  Future<Either<Failure, ServiceRequestEntity>> call(String id) => repository.finish(id);
}

class ConfirmServiceRequestUseCase {
  final ServiceRequestsRepository repository;
  const ConfirmServiceRequestUseCase(this.repository);

  Future<Either<Failure, ServiceRequestEntity>> call(String id) => repository.confirm(id);
}
