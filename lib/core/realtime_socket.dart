import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'api_client.dart';
import 'realtime_config.dart';

class RealtimeSocket {
  final ApiClient _client;
  WebSocketChannel? _channel;
  Stream<Map<String, dynamic>>? _broadcastStream;

  RealtimeSocket(this._client);

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
