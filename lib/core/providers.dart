import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';
import 'realtime_socket.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final realtimeSocketProvider = Provider<RealtimeSocket>((ref) {
  final socket = RealtimeSocket(ref.read(apiClientProvider));
  ref.onDispose(socket.dispose);
  return socket;
});
