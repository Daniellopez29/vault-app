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
}
