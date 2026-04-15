import 'package:shared_preferences/shared_preferences.dart';

class ThemeController {
  static bool isDark = true;

  static Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    isDark = prefs.getBool('isDark') ?? true;
  }

  static Future<void> saveTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', value);
  }
}
