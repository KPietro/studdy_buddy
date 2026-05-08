import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/settings_controller.dart';

class ConfigPage extends StatelessWidget {
  const ConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsController>(context);

    final bool isDark = settings.isDarkMode;

    final Color bgColor =
        isDark ? const Color(0xFF1D0000) : const Color(0xFFEAFaf1);

    final Color cardColor =
        isDark ? const Color(0xFF2A2A2A) : Colors.white;

    final Color textColor =
        isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,

      appBar: AppBar(
        backgroundColor:
            isDark ? const Color(0xFF4A0000) : Colors.green,
        title: const Text(
          "Configurações",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          _buildCard(
            color: cardColor,
            child: SwitchListTile(
              title: Text(
                "Tema escuro",
                style: TextStyle(color: textColor),
              ),
              value: settings.isDarkMode,
              onChanged: (value) =>
                  settings.toggleDarkMode(value),
            ),
          ),

          const SizedBox(height: 12),

          _buildCard(
            color: cardColor,
            child: SwitchListTile(
              title: Text(
                "Notificações",
                style: TextStyle(color: textColor),
              ),
              value: settings.notifications,
              onChanged: (value) =>
                  settings.setNotifications(value),
            ),
          ),

          const SizedBox(height: 12),

          _buildCard(
            color: cardColor,
            child: SwitchListTile(
              title: Text(
                "Perfil privado",
                style: TextStyle(color: textColor),
              ),
              subtitle: Text(
                "Oculta seu progresso e atividades",
                style: TextStyle(color: textColor),
              ),
              value: settings.privacy,
              onChanged: (value) =>
                  settings.setPrivacy(value),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            "Idioma",
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<String>(
              dropdownColor: cardColor,
              value: settings.language,
              isExpanded: true,
              underline: const SizedBox(),
              style: TextStyle(color: textColor),
              items: [
                DropdownMenuItem(
                  value: "pt",
                  child: Text(
                    "Português",
                    style: TextStyle(color: textColor),
                  ),
                ),
                DropdownMenuItem(
                  value: "en",
                  child: Text(
                    "Inglês",
                    style: TextStyle(color: textColor),
                  ),
                ),
                DropdownMenuItem(
                  value: "es",
                  child: Text(
                    "Espanhol",
                    style: TextStyle(color: textColor),
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  settings.setLanguage(value);
                }
              },
            ),
          ),

          const SizedBox(height: 20),

          Text(
            "Tamanho da fonte",
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),

          Slider(
            value: settings.fontSize,
            min: 12,
            max: 24,
            divisions: 6,
            label: settings.fontSize.toString(),
            onChanged: (value) =>
                settings.setFontSize(value),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required Widget child,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: child,
    );
  }
}