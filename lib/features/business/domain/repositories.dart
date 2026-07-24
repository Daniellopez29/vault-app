import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import 'entities.dart';

abstract class BusinessRepository {
  /// El negocio del usuario actual, o `null` si no tiene uno registrado.
  Future<Either<Failure, BusinessEntity?>> getMyBusiness();

  Future<Either<Failure, BusinessEntity>> updateBusiness(BusinessEntity business);

  /// Todos los negocios registrados en la plataforma, para el directorio
  /// público del Shop.
  Future<Either<Failure, List<BusinessEntity>>> getAllBusinesses();

  Future<Either<Failure, BusinessEntity>> uploadPhoto(
    String id, {
    required List<int> bytes,
    required String filename,
  });

  Future<Either<Failure, BusinessEntity>> deletePhoto(String id, String photoId);
}
