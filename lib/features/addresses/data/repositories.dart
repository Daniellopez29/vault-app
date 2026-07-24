import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';
import 'datasources.dart';

class AddressesRepositoryImpl implements AddressesRepository {
  final AddressesDataSource dataSource;

  AddressesRepositoryImpl({required this.dataSource});

  // El datasource devuelve List<AddressModel>; Dart preserva ese tipo en
  // tiempo de ejecución aunque la firma diga List<AddressEntity> (los
  // genéricos son covariantes). Eso rompía firstWhere(orElse: ...) en
  // checkout_address_page.dart con "type '() => AddressEntity' is not a
  // subtype of type '(() => AddressModel)?'". List.of(...) construye una
  // lista nueva con el tipo declarado real.
  List<AddressEntity> _asEntities(List<AddressEntity> addresses) =>
      List<AddressEntity>.of(addresses);

  @override
  Future<Either<Failure, List<AddressEntity>>> getAddresses() async {
    try {
      return Right(_asEntities(await dataSource.getAddresses()));
    } catch (_) {
      return const Left(ServerFailure('Error al cargar tus direcciones.'));
    }
  }

  @override
  Future<Either<Failure, List<AddressEntity>>> addAddress(
      AddressEntity address) async {
    try {
      return Right(_asEntities(await dataSource.addAddress(address)));
    } catch (_) {
      return const Left(ServerFailure('Error al guardar la direccion.'));
    }
  }

  @override
  Future<Either<Failure, List<AddressEntity>>> deleteAddress(
      String addressId) async {
    try {
      return Right(_asEntities(await dataSource.deleteAddress(addressId)));
    } catch (_) {
      return const Left(ServerFailure('Error al eliminar la direccion.'));
    }
  }

  @override
  Future<Either<Failure, List<AddressEntity>>> setDefault(
      String addressId) async {
    try {
      return Right(_asEntities(await dataSource.setDefault(addressId)));
    } catch (_) {
      return const Left(ServerFailure('Error al actualizar la direccion.'));
    }
  }
}