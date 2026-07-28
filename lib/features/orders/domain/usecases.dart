import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import 'entities.dart';
import 'repositories.dart';

class CreateOrderParams {
  final String sellerId;
  final String assetId;
  final int amountCents;
  final String buyerEmail;
  final String paymentMethodId;

  const CreateOrderParams({
    required this.sellerId,
    required this.assetId,
    required this.amountCents,
    required this.buyerEmail,
    required this.paymentMethodId,
  });
}

class CreateOrderUseCase {
  final OrderRepository repository;
  const CreateOrderUseCase(this.repository);

  Future<Either<Failure, OrderEntity>> call(CreateOrderParams params) => repository.createOrder(
        sellerId: params.sellerId,
        assetId: params.assetId,
        amountCents: params.amountCents,
        buyerEmail: params.buyerEmail,
        paymentMethodId: params.paymentMethodId,
      );
}

class GetMyOrdersUseCase {
  final OrderRepository repository;
  const GetMyOrdersUseCase(this.repository);

  Future<Either<Failure, List<OrderEntity>>> call() => repository.getMyOrders();
}

class GetMySalesUseCase {
  final OrderRepository repository;
  const GetMySalesUseCase(this.repository);

  Future<Either<Failure, List<OrderEntity>>> call() => repository.getMySales();
}

class ConfirmOrderUseCase {
  final OrderRepository repository;
  const ConfirmOrderUseCase(this.repository);

  Future<Either<Failure, OrderEntity>> call(String id) => repository.confirmOrder(id);
}

class ShipOrderUseCase {
  final OrderRepository repository;
  const ShipOrderUseCase(this.repository);

  Future<Either<Failure, OrderEntity>> call(String id) => repository.shipOrder(id);
}
