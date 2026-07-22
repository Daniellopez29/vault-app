import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import 'entities.dart';

abstract class BusinessRepository {
  /// El negocio del usuario actual, o `null` si no tiene uno registrado.
  Future<Either<Failure, BusinessEntity?>> getMyBusiness();

  Future<Either<Failure, BusinessEntity>> updateBusiness(BusinessEntity business);
}
