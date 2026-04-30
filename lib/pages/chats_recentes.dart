import 'package:flutter/material.dart';
import 'chat_page.dart';

class ChatsRecentesPage extends StatelessWidget {
  final bool isDark;

  const ChatsRecentesPage({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats Recentes"),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text("Grupo Estudos"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatPage(
                    isDark: isDark,
                    grupoNome: "Grupo Estudos",
                    grupoId: "xtMuniqz8rcijR03NZ5d",
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
