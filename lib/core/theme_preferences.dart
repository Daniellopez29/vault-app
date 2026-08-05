import 'package:shared_preferences/shared_preferences.dart';

class ThemePreferences {
  static const _key = 'vault_dark_mode';

  static Future<bool> loadIsDark() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  static Future<void> save(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, isDark);
  }
}
