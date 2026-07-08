import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';
import 'datasources.dart';
import 'models.dart';

class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource localDataSource;

  CartRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<CartItemEntity>>> getItems() =>
      _guard(() => localDataSource.getItems());

  @override
  Future<Either<Failure, List<CartItemEntity>>> addItem(CartItemEntity item) =>
      _guard(() => localDataSource.addItem(CartItemModel.fromEntity(item)));

  @override
  Future<Either<Failure, List<CartItemEntity>>> removeItem(String id) =>
      _guard(() => localDataSource.removeItem(id));

  @override
  Future<Either<Failure, List<CartItemEntity>>> updateQuantity(
      String id,
      int quantity,
      ) =>
      _guard(() => localDataSource.updateQuantity(id, quantity));

  @override
  Future<Either<Failure, List<CartItemEntity>>> clear() =>
      _guard(() => localDataSource.clear());

  @override
  Future<Either<Failure, List<PaymentMethodEntity>>> getPaymentMethods() async {
    try {
      final methods = await localDataSource.getPaymentMethods();
      return Right(methods);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  /// Envuelve las operaciones del carrito en Either, sin repetir el try/catch
  /// en cada método (una sola responsabilidad para el manejo de errores).
  Future<Either<Failure, List<CartItemEntity>>> _guard(
      Future<List<CartItemModel>> Function() action,
      ) async {
    try {
      final items = await action();
      return Right(items);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }
}