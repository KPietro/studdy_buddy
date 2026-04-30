import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/settings_controller.dart';

class ConfigPage extends StatelessWidget {
  const ConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsController>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Configurações")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          SwitchListTile(
            title: const Text("Tema escuro"),
            value: settings.isDarkMode,
            onChanged: (value) => settings.toggleDarkMode(value),
          ),

          SwitchListTile(
            title: const Text("Notificações"),
            value: settings.notifications,
            onChanged: (value) => settings.setNotifications(value),
          ),

          SwitchListTile(
            title: const Text("Privacidade"),
            value: settings.privacy,
            onChanged: (value) => settings.setPrivacy(value),
          ),

          const SizedBox(height: 20),

          const Text("Idioma"),
          DropdownButton<String>(
            value: settings.language,
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: "pt", child: Text("Português")),
              DropdownMenuItem(value: "en", child: Text("Inglês")),
              DropdownMenuItem(value: "es", child: Text("Espanhol")),
            ],
            onChanged: (value) {
              if (value != null) settings.setLanguage(value);
            },
          ),

          const SizedBox(height: 20),

          const Text("Tamanho da fonte"),
          Slider(
            value: settings.fontSize,
            min: 12,
            max: 24,
            divisions: 6,
            label: settings.fontSize.toString(),
            onChanged: (value) => settings.setFontSize(value),
          ),
        ],
      ),
    );
  }
}