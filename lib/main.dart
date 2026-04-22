import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:device_preview/device_preview.dart';

// 1. OLHA O IMPORT DO FIREBASE AQUI! Faltava isso!
import 'package:firebase_core/firebase_core.dart';

import 'controllers/theme_controller.dart';
import 'pages/login.dart';

void main() async {
  // Garante que o Flutter tá pronto
  WidgetsFlutterBinding.ensureInitialized();

  // 2. ACORDA O FIREBASE! Isso aqui resolve o seu erro vermelho!
  await Firebase.initializeApp();

  // Carrega o seu tema
  await ThemeController.loadTheme();

  // Roda o app
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const StuddyBuddyApp(),
    ),
  );
}
class StuddyBuddyApp extends StatelessWidget {
  const StuddyBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      title: 'Studdy-Buddy',
      home: const LoginPage(),
    );
  }
}
