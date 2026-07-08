import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import '../../../core/usecase.dart';
import 'entities.dart';
import 'repositories.dart';
import 'package:equatable/equatable.dart';

class GetCartItemsUseCase implements UseCase<List<CartItemEntity>, NoParams> {
  final CartRepository repository;
  const GetCartItemsUseCase(this.repository);

  @override
  Future<Either<Failure, List<CartItemEntity>>> call(NoParams params) =>
      repository.getItems();
}

class AddCartItemUseCase implements UseCase<List<CartItemEntity>, CartItemEntity> {
  final CartRepository repository;
  const AddCartItemUseCase(this.repository);

  @override
  Future<Either<Failure, List<CartItemEntity>>> call(CartItemEntity item) =>
      repository.addItem(item);
}

class RemoveCartItemUseCase implements UseCase<List<CartItemEntity>, String> {
  final CartRepository repository;
  const RemoveCartItemUseCase(this.repository);

  @override
  Future<Either<Failure, List<CartItemEntity>>> call(String id) =>
      repository.removeItem(id);
}

class UpdateCartQuantityUseCase
    implements UseCase<List<CartItemEntity>, UpdateQuantityParams> {
  final CartRepository repository;
  const UpdateCartQuantityUseCase(this.repository);

  @override
  Future<Either<Failure, List<CartItemEntity>>> call(
      UpdateQuantityParams params) =>
      repository.updateQuantity(params.id, params.quantity);
}

class ClearCartUseCase implements UseCase<List<CartItemEntity>, NoParams> {
  final CartRepository repository;
  const ClearCartUseCase(this.repository);

  @override
  Future<Either<Failure, List<CartItemEntity>>> call(NoParams params) =>
      repository.clear();
}

class GetPaymentMethodsUseCase
    implements UseCase<List<PaymentMethodEntity>, NoParams> {
  final CartRepository repository;
  const GetPaymentMethodsUseCase(this.repository);

  @override
  Future<Either<Failure, List<PaymentMethodEntity>>> call(NoParams params) =>
      repository.getPaymentMethods();
}

class UpdateQuantityParams extends Equatable {
  final String id;
  final int quantity;

  const UpdateQuantityParams({required this.id, required this.quantity});

  @override
  List<Object?> get props => [id, quantity];
}