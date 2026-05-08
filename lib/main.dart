import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:provider/provider.dart';
import 'controllers/settings_controller.dart';
import 'controllers/theme_controller.dart';

import 'pages/login.dart';
import 'pages/auth_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await ThemeController.loadTheme();

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
    final settings = Provider.of<SettingsController>(context);

    return MaterialApp(
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),

      builder: (context, child) {
        child = DevicePreview.appBuilder(context, child);

        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              settings.fontSize / 16,
            ),
          ),
          child: child!,
        );
      },

      debugShowCheckedModeBanner: false,
      title: 'Studdy-Buddy',

      // 🔥 CORREÇÃO REAL DO TEMA GLOBAL
      themeMode: settings.isDarkMode
          ? ThemeMode.dark
          : ThemeMode.light,

      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),

      home: const AuthCheck(),
    );
  }
}