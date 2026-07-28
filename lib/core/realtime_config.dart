import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart';

class RealtimeConfig {
  static const _overrideKey = 'vault_realtime_ws_url';

  static String? _override;

  static String get wsUrl {
    if (_override != null && _override!.isNotEmpty) return _override!;
    final base = ApiConfig.baseUrl.replaceFirst(RegExp(r'/api/v1/?$'), '');
    return '${base.replaceFirst('https://', 'wss://').replaceFirst('http://', 'ws://')}/ws';
  }

  static Future<void> loadOverride() async {
    final prefs = await SharedPreferences.getInstance();
    _override = prefs.getString(_overrideKey);
  }

  static Future<void> setOverride(String? url) async {
    _override = (url == null || url.trim().isEmpty) ? null : url.trim();
    final prefs = await SharedPreferences.getInstance();
    if (_override == null) {
      await prefs.remove(_overrideKey);
    } else {
      await prefs.setString(_overrideKey, _override!);
    }
  }
}
