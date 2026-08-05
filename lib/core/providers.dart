import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';

import 'token_storage.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

/// Instancia única del cliente HTTP, compartida por todas las features.
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

/// Cliente HTTP hacia `payment/` (Stripe: suscripciones, ads, órdenes) --
/// servicio Go separado de `api/`, ver [PaymentApiConfig].
final paymentApiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(baseUrlOverride: PaymentApiConfig.baseUrl),
);
