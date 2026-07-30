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

  /// Pedidos donde el usuario en sesión es el comprador -- "Mis pedidos".
  Future<List<OrderModel>> getMyOrders();

  /// Pedidos donde el usuario en sesión es el vendedor -- "Mis ventas".
  Future<List<OrderModel>> getMySales();

  /// El comprador confirma que recibió el producto -- libera el escrow.
  /// Falla si la orden todavía no está en estado "enviado".
  Future<OrderModel> confirmOrder(String id);

  /// El vendedor marca el pedido como enviado -- paso de logística
  /// requerido antes de que el comprador pueda confirmar recibido.
  Future<OrderModel> shipOrder(String id);

  /// `GET /orders/has-purchased` -- endpoint deliberadamente público del
  /// lado del backend, pero igual pasa por el mismo ApiClient.
  Future<bool> hasPurchased({required String buyerId, required String sellerId});
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

  @override
  Future<List<OrderModel>> getMyOrders() async {
    try {
      final body = await _client.get('/orders/mine');
      final list = (body as Map<String, dynamic>)['orders'] as List<dynamic>? ?? const [];
      return list.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al cargar tus pedidos: $e');
    }
  }

  @override
  Future<List<OrderModel>> getMySales() async {
    try {
      final body = await _client.get('/orders/selling');
      final list = (body as Map<String, dynamic>)['orders'] as List<dynamic>? ?? const [];
      return list.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al cargar tus ventas: $e');
    }
  }

  @override
  Future<OrderModel> confirmOrder(String id) async {
    try {
      final body = await _client.post('/orders/$id/confirm');
      return OrderModel.fromJson(body as Map<String, dynamic>);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al confirmar el pedido: $e');
    }
  }

  @override
  Future<OrderModel> shipOrder(String id) async {
    try {
      final body = await _client.post('/orders/$id/ship');
      return OrderModel.fromJson(body as Map<String, dynamic>);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al marcar el pedido como enviado: $e');
    }
  }

  @override
  Future<bool> hasPurchased({required String buyerId, required String sellerId}) async {
    try {
      final body = await _client.get('/orders/has-purchased', query: {
        'buyer_id': buyerId,
        'seller_id': sellerId,
      });
      return (body as Map<String, dynamic>)['purchased'] as bool? ?? false;
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al verificar la compra: $e');
    }
  }
}
