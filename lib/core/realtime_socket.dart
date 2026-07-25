import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'api_client.dart';

/// Socket compartido para eventos en vivo -- `realtime/` multiplexa chat y
/// notificaciones sobre la MISMA conexión, con un discriminador `event` en
/// cada payload ("chat_message" / "notification"). Conecta una sola vez
/// por sesión de login (stream broadcast, lazy) y la reutilizan tanto
/// `chat` como `notifications`.
///
/// `AuthController` invalida el provider de esta clase al cerrar sesión
/// (ver `features/auth/presentation/providers.dart`) para que la próxima
/// cuenta que inicie sesión en el mismo dispositivo abra su propia
/// conexión en vez de quedarse escuchando la de la cuenta anterior.
class RealtimeSocket {
  final ApiClient _client;
  WebSocketChannel? _channel;
  Stream<Map<String, dynamic>>? _broadcastStream;

  RealtimeSocket(this._client);

  /// Eventos crudos ya decodificados, cada uno con su 'event' discriminador
  /// intacto -- cada feature filtra y parsea los que le tocan.
  Stream<Map<String, dynamic>> events() {
    return _broadcastStream ??= _connect().asBroadcastStream();
  }

  Stream<Map<String, dynamic>> _connect() async* {
    final token = await _client.getToken();
    if (token == null) return;

    _channel = WebSocketChannel.connect(Uri.parse('${RealtimeConfig.wsUrl}?token=$token'));
    await for (final raw in _channel!.stream) {
      try {
        yield jsonDecode(raw as String) as Map<String, dynamic>;
      } catch (_) {
        continue;
      }
    }
  }

  void dispose() {
    _channel?.sink.close();
    _channel = null;
    _broadcastStream = null;
  }
}
