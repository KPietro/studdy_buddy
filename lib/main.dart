import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';

// 🔥 NOVOS IMPORTS
import 'package:provider/provider.dart';
import 'controllers/settings_controller.dart';

import 'controllers/theme_controller.dart';
import 'pages/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await ThemeController.loadTheme();

  // 🔥 NOVO: carregar configurações
  final settings = SettingsController();
  await settings.loadSettings();

  runApp(
    ChangeNotifierProvider(
      create: (_) => settings,
      child: DevicePreview(
        enabled: !kReleaseMode,
        builder: (context) => const StuddyBuddyApp(),
      ),
    ),
  );
}

class StuddyBuddyApp extends StatelessWidget {
  const StuddyBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔥 NOVO
    final settings = Provider.of<SettingsController>(context);

    return MaterialApp(
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      title: 'Studdy-Buddy',

      // 🔥 TEMA GLOBAL
      theme: ThemeData(
        brightness:
            settings.isDarkMode ? Brightness.dark : Brightness.light,
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontSize: settings.fontSize),
        ),
      ),

      home: const LoginPage(),
    );
  }
}