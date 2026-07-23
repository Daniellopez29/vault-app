import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';
import 'datasources.dart';

class AddressesRepositoryImpl implements AddressesRepository {
  final AddressesDataSource dataSource;

  AddressesRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, List<AddressEntity>>> getAddresses() async {
    try {
      return Right(await dataSource.getAddresses());
    } catch (_) {
      return const Left(ServerFailure('Error al cargar tus direcciones.'));
    }
  }

  @override
  Future<Either<Failure, List<AddressEntity>>> addAddress(
      AddressEntity address) async {
    try {
      return Right(await dataSource.addAddress(address));
    } catch (_) {
      return const Left(ServerFailure('Error al guardar la direccion.'));
    }
  }

  @override
  Future<Either<Failure, List<AddressEntity>>> deleteAddress(
      String addressId) async {
    try {
      return Right(await dataSource.deleteAddress(addressId));
    } catch (_) {
      return const Left(ServerFailure('Error al eliminar la direccion.'));
    }
  }

  @override
  Future<Either<Failure, List<AddressEntity>>> setDefault(
      String addressId) async {
    try {
      return Right(await dataSource.setDefault(addressId));
    } catch (_) {
      return const Left(ServerFailure('Error al actualizar la direccion.'));
    }
  }
}