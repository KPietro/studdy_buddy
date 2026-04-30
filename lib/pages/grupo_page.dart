import 'package:flutter/material.dart';
import 'chat_page.dart';

class GrupoPage extends StatelessWidget {
  final bool isDark;
  final String grupoNome;
  final String grupoId;

  const GrupoPage({
    super.key,
    required this.isDark,
    required this.grupoNome,
    required this.grupoId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(grupoNome),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text("Abrir Chat"),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatPage(
                  isDark: isDark,
                  grupoNome: grupoNome,
                  grupoId: grupoId,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
