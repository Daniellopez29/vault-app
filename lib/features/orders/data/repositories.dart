import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';
import 'datasources.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource _remote;

  OrderRepositoryImpl({required OrderRemoteDataSource remote}) : _remote = remote;

  @override
  Future<Either<Failure, OrderEntity>> createOrder({
    required String sellerId,
    required String assetId,
    required int amountCents,
    required String buyerEmail,
    required String paymentMethodId,
  }) async {
    try {
      final order = await _remote.createOrder(
        sellerId: sellerId,
        assetId: assetId,
        amountCents: amountCents,
        buyerEmail: buyerEmail,
        paymentMethodId: paymentMethodId,
      );
      return Right(order);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Error al procesar el pago: $e'));
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getMyOrders() async {
    try {
      final orders = await _remote.getMyOrders();
      return Right(orders);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Error al cargar tus pedidos: $e'));
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getMySales() async {
    try {
      final orders = await _remote.getMySales();
      return Right(orders);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Error al cargar tus ventas: $e'));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> confirmOrder(String id) async {
    try {
      final order = await _remote.confirmOrder(id);
      return Right(order);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Error al confirmar el pedido: $e'));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> shipOrder(String id) async {
    try {
      final order = await _remote.shipOrder(id);
      return Right(order);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Error al marcar el pedido como enviado: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasPurchased({required String buyerId, required String sellerId}) async {
    try {
      final result = await _remote.hasPurchased(buyerId: buyerId, sellerId: sellerId);
      return Right(result);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Error al verificar la compra: $e'));
    }
  }
}
