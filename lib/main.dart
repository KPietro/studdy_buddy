import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';

// 🔥 NOVOS IMPORTS
import 'package:provider/provider.dart';
import 'controllers/settings_controller.dart';
import 'controllers/theme_controller.dart';

// Importando a tela de Login e o novo AuthCheck
import 'pages/login.dart';
import 'pages/auth_check.dart'; // 🔥 NOVO: Import do arquivo que criamos!

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await ThemeController.loadTheme();

  // 🔥 NOVO: carregar configurações (MANTIDO INTACTO)
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
    // 🔥 NOVO (MANTIDO INTACTO)
    final settings = Provider.of<SettingsController>(context);

    return MaterialApp(
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      title: 'Studdy-Buddy',

      // 🔥 TEMA GLOBAL (MANTIDO INTACTO)
      theme: ThemeData(
        brightness: settings.isDarkMode ? Brightness.dark : Brightness.light,
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontSize: settings.fontSize),
        ),
      ),

      // 🔥 A MÁGICA ACONTECE AQUI:
      // Em vez de ir pro LoginPage, ele vai pro AuthCheck ver se tem alguém logado!
      home: const AuthCheck(),
    );
  }
}
