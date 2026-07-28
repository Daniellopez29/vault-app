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

class UploadBusinessPhotoParams {
  final String businessId;
  final List<int> bytes;
  final String filename;

  const UploadBusinessPhotoParams({
    required this.businessId,
    required this.bytes,
    required this.filename,
  });
}

class UploadBusinessPhotoUseCase
    implements UseCase<BusinessEntity, UploadBusinessPhotoParams> {
  final BusinessRepository repository;

  UploadBusinessPhotoUseCase(this.repository);

  @override
  Future<Either<Failure, BusinessEntity>> call(UploadBusinessPhotoParams params) {
    return repository.uploadPhoto(params.businessId, bytes: params.bytes, filename: params.filename);
  }
}

class DeleteBusinessPhotoParams {
  final String businessId;
  final String photoId;

  const DeleteBusinessPhotoParams({required this.businessId, required this.photoId});
}

class DeleteBusinessPhotoUseCase
    implements UseCase<BusinessEntity, DeleteBusinessPhotoParams> {
  final BusinessRepository repository;

  DeleteBusinessPhotoUseCase(this.repository);

  @override
  Future<Either<Failure, BusinessEntity>> call(DeleteBusinessPhotoParams params) {
    return repository.deletePhoto(params.businessId, params.photoId);
  }
}

class GetBusinessServicesUseCase implements UseCase<List<BusinessServiceEntity>, String> {
  final BusinessRepository repository;
  GetBusinessServicesUseCase(this.repository);

  @override
  Future<Either<Failure, List<BusinessServiceEntity>>> call(String businessId) {
    return repository.getServices(businessId);
  }
}

class BusinessServiceParams {
  final String businessId;
  final String? serviceId;
  final String title;
  final String description;
  final double price;

  const BusinessServiceParams({
    required this.businessId,
    this.serviceId,
    required this.title,
    required this.description,
    required this.price,
  });
}

class CreateBusinessServiceUseCase
    implements UseCase<BusinessServiceEntity, BusinessServiceParams> {
  final BusinessRepository repository;
  CreateBusinessServiceUseCase(this.repository);

  @override
  Future<Either<Failure, BusinessServiceEntity>> call(BusinessServiceParams params) {
    return repository.createService(
      params.businessId,
      title: params.title,
      description: params.description,
      price: params.price,
    );
  }
}

class UpdateBusinessServiceUseCase
    implements UseCase<BusinessServiceEntity, BusinessServiceParams> {
  final BusinessRepository repository;
  UpdateBusinessServiceUseCase(this.repository);

  @override
  Future<Either<Failure, BusinessServiceEntity>> call(BusinessServiceParams params) {
    return repository.updateService(
      params.businessId,
      params.serviceId!,
      title: params.title,
      description: params.description,
      price: params.price,
    );
  }
}

class DeleteBusinessServiceParams {
  final String businessId;
  final String serviceId;
  const DeleteBusinessServiceParams({required this.businessId, required this.serviceId});
}

class DeleteBusinessServiceUseCase
    implements UseCase<void, DeleteBusinessServiceParams> {
  final BusinessRepository repository;
  DeleteBusinessServiceUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteBusinessServiceParams params) {
    return repository.deleteService(params.businessId, params.serviceId);
  }
}
