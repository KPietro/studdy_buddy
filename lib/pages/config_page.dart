import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/settings_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';

class ConfigPage extends StatelessWidget {
  const ConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsController>(context);
    final bool isDark = settings.isDarkMode;

    // --- CORES DO TEMA PREMIUM ---
    final Color bgColor = isDark
        ? const Color(0xFF1D0000)
        : const Color(0xFFEAFaf1);
    final Color cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black87;

    // --- SOMBRA SUAVE ---
    final List<BoxShadow>? shadowClara = isDark
        ? null
        : [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF4A0000) : Colors.green[700],
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
            shadow: shadowClara,
            child: SwitchListTile(
              title: Text("Tema escuro", style: TextStyle(color: textColor)),
              value: settings.isDarkMode,
              onChanged: (value) => settings.toggleDarkMode(value),
            ),
          ),
          const SizedBox(height: 12),
          _buildCard(
            color: cardColor,
            shadow: shadowClara,
            child: SwitchListTile(
              title: Text("Notificações", style: TextStyle(color: textColor)),
              value: settings.notifications,
              onChanged: (value) => settings.setNotifications(value),
            ),
          ),
          const SizedBox(height: 12),
          _buildCard(
            color: cardColor,
            shadow: shadowClara,
            child: SwitchListTile(
              title: Text("Perfil privado", style: TextStyle(color: textColor)),
              subtitle: Text(
                "Oculta seu progresso e atividades",
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              value: settings.privacy,
              onChanged: (value) => settings.setPrivacy(value),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            "Idioma",
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: shadowClara,
            ),
            child: DropdownButton<String>(
              dropdownColor: cardColor,
              value: settings.language,
              isExpanded: true,
              underline: const SizedBox(),
              style: TextStyle(color: textColor),
              items: const [
                DropdownMenuItem(value: "pt", child: Text("Português")),
                DropdownMenuItem(value: "en", child: Text("Inglês")),
                DropdownMenuItem(value: "es", child: Text("Espanhol")),
              ],
              onChanged: (value) =>
                  value != null ? settings.setLanguage(value) : null,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Tamanho da fonte",
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
          Slider(
            value: settings.fontSize,
            min: 12,
            max: 24,
            divisions: 6,
            activeColor: isDark ? Colors.red : Colors.green[700],
            label: settings.fontSize.toString(),
            onChanged: (value) => settings.setFontSize(value),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                "LOGOUT",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted)
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required Widget child,
    required Color color,
    List<BoxShadow>? shadow,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        boxShadow: shadow,
      ),
      child: child,
    );
  }
}
