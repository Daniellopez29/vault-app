import '../../../core/api_client.dart';
import '../../../core/error.dart';
import '../domain/entities.dart';
import 'models.dart';

abstract class SubscriptionDataSource {
  Future<List<SubscriptionPlanModel>> getPlans(SubscriptionType type);

  Future<SubscriptionStatusModel> createSubscription({
    required String planId,
    required String email,
    required String paymentMethodId,
  });
}

/// `payment/` vende 3 planes fijos (básico/pro/premium), sin distinguir por
/// tipo de anuncio -- `type` solo se conserva en la firma para no romper al
/// resto de la app (copy/entrada de pantalla), pero ya no filtra la lista.
class SubscriptionRemoteDataSource implements SubscriptionDataSource {
  final ApiClient _client;

  SubscriptionRemoteDataSource(this._client);

  @override
  Future<List<SubscriptionPlanModel>> getPlans(SubscriptionType type) async {
    try {
      final body = await _client.get('/subscriptions/plans', auth: false);
      final list = body as List<dynamic>? ?? const [];
      return list.map((e) => SubscriptionPlanModel.fromJson(e as Map<String, dynamic>)).toList();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al cargar los planes: $e');
    }
  }

  @override
  Future<SubscriptionStatusModel> createSubscription({
    required String planId,
    required String email,
    required String paymentMethodId,
  }) async {
    try {
      final body = await _client.post('/subscriptions', body: {
        'plan_id': planId,
        'email': email,
        'payment_method_id': paymentMethodId,
      });
      return SubscriptionStatusModel.fromJson(body as Map<String, dynamic>);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al crear la suscripción: $e');
    }
  }
}
