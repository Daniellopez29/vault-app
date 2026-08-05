import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';
import 'realtime_socket.dart';
import 'theme.dart';
import 'theme_preferences.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final realtimeSocketProvider = Provider<RealtimeSocket>((ref) {
  final socket = RealtimeSocket(ref.read(apiClientProvider));
  ref.onDispose(socket.dispose);
  return socket;
});

/// Arranca en modo claro; `main()` sobreescribe el estado inicial con la
/// preferencia guardada antes de `runApp` (mismo patrón que `ApiConfig`).
class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController(super.state);

  void toggle() {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    VaultTheme.syncBrightness(
      next == ThemeMode.dark ? Brightness.dark : Brightness.light,
    );
    state = next;
    ThemePreferences.save(next == ThemeMode.dark);
  }
}

final themeModeControllerProvider =
    StateNotifierProvider<ThemeModeController, ThemeMode>(
      (ref) => ThemeModeController(ThemeMode.light),
    );
