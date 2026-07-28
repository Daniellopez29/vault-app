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
}
