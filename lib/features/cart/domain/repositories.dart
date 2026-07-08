import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import 'entities.dart';

abstract class CartRepository {
  Future<Either<Failure, List<CartItemEntity>>> getItems();
  Future<Either<Failure, List<CartItemEntity>>> addItem(CartItemEntity item);
  Future<Either<Failure, List<CartItemEntity>>> removeItem(String id);
  Future<Either<Failure, List<CartItemEntity>>> updateQuantity(
      String id,
      int quantity,
      );
  Future<Either<Failure, List<CartItemEntity>>> clear();
  Future<Either<Failure, List<PaymentMethodEntity>>> getPaymentMethods();
}