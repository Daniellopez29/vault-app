import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import '../../../core/usecase.dart';
import 'entities.dart';
import 'repositories.dart';

class GetMyBusinessUseCase implements UseCase<BusinessEntity?, NoParams> {
  final BusinessRepository repository;

  GetMyBusinessUseCase(this.repository);

  @override
  Future<Either<Failure, BusinessEntity?>> call(NoParams params) {
    return repository.getMyBusiness();
  }
}

class UpdateBusinessUseCase implements UseCase<BusinessEntity, BusinessEntity> {
  final BusinessRepository repository;

  UpdateBusinessUseCase(this.repository);

  @override
  Future<Either<Failure, BusinessEntity>> call(BusinessEntity business) {
    return repository.updateBusiness(business);
  }
}

/// Trae el directorio completo de negocios registrados, para mostrarlos en
/// el Shop.
class GetAllBusinessesUseCase
    implements UseCase<List<BusinessEntity>, NoParams> {
  final BusinessRepository repository;

  GetAllBusinessesUseCase(this.repository);

  @override
  Future<Either<Failure, List<BusinessEntity>>> call(NoParams params) {
    return repository.getAllBusinesses();
  }
}
