import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import 'entities.dart';

abstract class OrderRepository {
  /// Cobra al comprador vía Stripe y deja el monto en escrow para
  /// [sellerId] -- falla con `ErrSellerNotOnboarded` (mensaje del backend,
  /// llega como el texto de un ServerFailure) si el vendedor no completó
  /// el onboarding de Stripe Connect (ver `features/connect/`).
  Future<Either<Failure, OrderEntity>> createOrder({
    required String sellerId,
    required String assetId,
    required int amountCents,
    required String buyerEmail,
    required String paymentMethodId,
  });

  Future<Either<Failure, List<OrderEntity>>> getMyOrders();

  Future<Either<Failure, List<OrderEntity>>> getMySales();

  Future<Either<Failure, OrderEntity>> confirmOrder(String id);

  Future<Either<Failure, OrderEntity>> shipOrder(String id);

  /// Si [buyerId] le compró algo (con orden liberada) a [sellerId] -- usado
  /// para decidir si mostrar el compositor de comentarios en la publicación
  /// de un vendedor (el backend aplica la misma regla en `assetcomments`).
  Future<Either<Failure, bool>> hasPurchased({required String buyerId, required String sellerId});
}
