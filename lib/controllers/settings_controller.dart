import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends ChangeNotifier {
  bool isDarkMode = false;
  bool notifications = true;
  bool privacy = false;
  double fontSize = 16;
  String language = "pt";

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    isDarkMode = prefs.getBool("darkMode") ?? false;
    notifications = prefs.getBool("notifications") ?? true;
    privacy = prefs.getBool("privacy") ?? false;
    fontSize = prefs.getDouble("fontSize") ?? 16;
    language = prefs.getString("language") ?? "pt";

    notifyListeners();
  }

  Future<void> toggleDarkMode(bool value) async {
    isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("darkMode", value);
    notifyListeners();
  }

  Future<void> setNotifications(bool value) async {
    notifications = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("notifications", value);
    notifyListeners();
  }

  Future<void> setPrivacy(bool value) async {
    privacy = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("privacy", value);
    notifyListeners();
  }

  Future<void> setFontSize(double value) async {
    fontSize = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble("fontSize", value);
    notifyListeners();
  }

  Future<void> setLanguage(String value) async {
    language = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("language", value);
    notifyListeners();
  }
}