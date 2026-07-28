import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static const _overrideKey = 'vault_api_base_url';

  static const _productionDefault =
      'https://humorous-nurturing-production-9cd4.up.railway.app/api/v1';

  static String? _override;

  static String get baseUrl {
    if (_override != null && _override!.isNotEmpty) return _override!;
    return _productionDefault;
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
