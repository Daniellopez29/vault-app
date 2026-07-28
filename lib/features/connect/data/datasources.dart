import '../../../core/api_client.dart';
import '../../../core/error.dart';
import 'models.dart';

abstract class ConnectRemoteDataSource {
  Future<ConnectStatusModel> getStatus();

  Future<String> createOnboardingLink({
    required String email,
    required String refreshUrl,
    required String returnUrl,
  });
}

/// `payment/` -- mismo host que `SubscriptionRemoteDataSource`, ruteado
/// por el gateway bajo `/api/v1/connect`.
class ConnectRemoteDataSourceImpl implements ConnectRemoteDataSource {
  final ApiClient _client;

  ConnectRemoteDataSourceImpl(this._client);

  @override
  Future<ConnectStatusModel> getStatus() async {
    try {
      final body = await _client.get('/connect/status');
      // {"account": null} si el vendedor nunca inició el onboarding (ver
      // GetAccountStatusUseCase.go) -- se trata igual que "sin cobros
      // habilitados", no como un error.
      final account = (body as Map<String, dynamic>)['account'];
      if (account == null) return const ConnectStatusModel(chargesEnabled: false);
      return ConnectStatusModel.fromJson(account as Map<String, dynamic>);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al consultar tu estado de cobros: $e');
    }
  }

  @override
  Future<String> createOnboardingLink({
    required String email,
    required String refreshUrl,
    required String returnUrl,
  }) async {
    try {
      final body = await _client.post('/connect/onboarding', body: {
        'email': email,
        'refresh_url': refreshUrl,
        'return_url': returnUrl,
      });
      return (body as Map<String, dynamic>)['url'] as String;
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al generar el link de registro: $e');
    }
  }
}
