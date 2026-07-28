import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'api_client.dart';
import 'realtime_config.dart';

/// Antes, `events()` armaba un `Stream` una sola vez (`_broadcastStream ??=`)
/// y lo dejaba cacheado para siempre: si el socket se caía por cualquier
/// motivo (el servidor cierra sockets zombie cada ~30s, el SO suspende el
/// socket en segundo plano, un corte de red), el generador terminaba y
/// TODOS los oyentes (chat, notificaciones, verificación de activos) se
/// quedaban escuchando un stream muerto en silencio por el resto de la
/// sesión -- de ahí que hubiera que recargar cada vista manualmente. Ahora
/// el `StreamController` es el único objeto expuesto a los oyentes y
/// persiste mientras dure la sesión; internamente esta clase reconecta con
/// backoff exponencial cada vez que la conexión se cae, igual que ya hacía
/// `realtime/` del lado de Postgres (`PostgresNotificationRepository.ts`).
class RealtimeSocket {
  final ApiClient _client;
  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _controller;
  StreamSubscription<dynamic>? _channelSubscription;
  Timer? _reconnectTimer;
  int _retryAttempt = 0;
  bool _disposed = false;

  RealtimeSocket(this._client);

  Stream<Map<String, dynamic>> events() {
    _controller ??= StreamController<Map<String, dynamic>>.broadcast(
      onListen: _connect,
    );
    return _controller!.stream;
  }

  /// Fuerza un intento de reconexión inmediato, saltándose el backoff en
  /// curso -- se llama al volver del segundo plano (`AppLifecycleState.resumed`
  /// en `main.dart`), porque el SO suele matar el socket mientras la app está
  /// suspendida sin que `onDone`/`onError` lleguen a dispararse hasta mucho
  /// después (o nunca). Si ya hay una conexión viva, no hace nada.
  void kick() {
    if (_disposed || _channel != null || _controller == null) return;
    _reconnectTimer?.cancel();
    _retryAttempt = 0;
    _connect();
  }

  Future<void> _connect() async {
    if (_disposed || _channel != null) return;

    final token = await _client.getToken();
    if (_disposed) return;
    if (token == null) {
      _scheduleReconnect();
      return;
    }

    try {
      final channel = WebSocketChannel.connect(Uri.parse('${RealtimeConfig.wsUrl}?token=$token'));
      await channel.ready;
      if (_disposed) {
        channel.sink.close();
        return;
      }

      _channel = channel;
      _retryAttempt = 0;
      _channelSubscription = channel.stream.listen(
        (raw) {
          try {
            _controller?.add(jsonDecode(raw as String) as Map<String, dynamic>);
          } catch (_) {
            // Mensaje no decodificable -- se ignora, no se rompe la conexión.
          }
        },
        onDone: _handleDisconnect,
        onError: (_) => _handleDisconnect(),
        cancelOnError: true,
      );
    } catch (_) {
      _handleDisconnect();
    }
  }

  void _handleDisconnect() {
    _channelSubscription?.cancel();
    _channelSubscription = null;
    _channel = null;
    _scheduleReconnect();
  }

  /// Backoff exponencial con techo de 30s -- mismo criterio que
  /// `PostgresNotificationRepository.ts` del lado de `realtime/`, para no
  /// martillar al servidor si está caído.
  void _scheduleReconnect() {
    if (_disposed) return;
    _reconnectTimer?.cancel();
    final delaySeconds = min(30, pow(2, _retryAttempt).toInt());
    _retryAttempt++;
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), _connect);
  }

  void dispose() {
    _disposed = true;
    _reconnectTimer?.cancel();
    _channelSubscription?.cancel();
    _channel?.sink.close();
    _channel = null;
    _controller?.close();
    _controller = null;
  }
}
