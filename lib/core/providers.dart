import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';
import 'realtime_socket.dart';

/// Instancia única del cliente HTTP, compartida por todas las features.
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

/// Instancia única del socket de eventos en vivo (chat + notificaciones),
/// compartida por todas las features. Ver [RealtimeSocket].
final realtimeSocketProvider = Provider<RealtimeSocket>((ref) {
  final socket = RealtimeSocket(ref.read(apiClientProvider));
  ref.onDispose(socket.dispose);
  return socket;
});

/// Cliente HTTP hacia `payment/` (Stripe: suscripciones, ads, órdenes) --
/// servicio Go separado de `api/`, ver [PaymentApiConfig].
final paymentApiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(baseUrlOverride: PaymentApiConfig.baseUrl),
);
