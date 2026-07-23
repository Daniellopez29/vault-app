import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import 'entities.dart';

/// Acceso a las direcciones de envio del usuario.
///
/// PENDIENTE DE BACKEND: hoy la implementacion es mock en memoria. Cuando
/// existan los endpoints, solo cambia la capa data.
abstract class AddressesRepository {
  Future<Either<Failure, List<AddressEntity>>> getAddresses();

  Future<Either<Failure, List<AddressEntity>>> addAddress(AddressEntity address);

  Future<Either<Failure, List<AddressEntity>>> deleteAddress(String addressId);

  /// Marca una direccion como predeterminada y desmarca las demas.
  Future<Either<Failure, List<AddressEntity>>> setDefault(String addressId);
}