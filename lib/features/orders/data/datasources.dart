import '../../../core/api_client.dart';
import '../../../core/error.dart';
import 'models.dart';

abstract class OrderRemoteDataSource {
  Future<OrderModel> createOrder({
    required String sellerId,
    required String assetId,
    required int amountCents,
    required String buyerEmail,
    required String paymentMethodId,
  });
}

/// `payment/` (Stripe: suscripciones, ads, órdenes) -- mismo host que
/// `SubscriptionRemoteDataSource`/`AdRemoteDataSourceImpl`, ruteado por el
/// gateway bajo `/api/v1/orders`.
class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final ApiClient _client;

  OrderRemoteDataSourceImpl(this._client);

  @override
  Future<OrderModel> createOrder({
    required String sellerId,
    required String assetId,
    required int amountCents,
    required String buyerEmail,
    required String paymentMethodId,
  }) async {
    try {
      final body = await _client.post('/orders', body: {
        'seller_id': sellerId,
        'asset_id': assetId,
        'amount_cents': amountCents,
        'buyer_email': buyerEmail,
        'payment_method_id': paymentMethodId,
      });
      return OrderModel.fromJson(body as Map<String, dynamic>);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al procesar el pago: $e');
    }
  }
}
