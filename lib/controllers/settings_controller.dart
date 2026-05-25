import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <-- Adicionado
import 'package:firebase_auth/firebase_auth.dart'; // <-- Adicionado

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

  // --- ATUALIZADO: Agora salva a privacidade no Firebase! ---
  Future<void> setPrivacy(bool value) async {
    privacy = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("privacy", value);

    // Atualiza no banco de dados para os outros usuários não conseguirem acessar
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .update({'perfil_privado': value});
    }

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
