import 'package:flutter/material.dart';
import 'chat_page.dart'; // Import para abrir o chat quando clicar

class ChatsRecentesPage extends StatelessWidget {
  final bool isDark;

  ChatsRecentesPage({super.key, required this.isDark});

  // 🔥 MOCK DOS CHATS RECENTES
  final List<Map<String, dynamic>> chatsRecentes = [
    {"nome": "Mari", "msg": "Você: Terminei o resumo de história!", "cor": Colors.purple, "letra": "M"},
    {"nome": "G1", "msg": "Tim: Alguém quer fazer call agora?", "cor": Colors.red, "letra": "G1"},
    {"nome": "Brayan", "msg": "Bora jogar um Valorant dps?", "cor": Colors.blue, "letra": "B"},
    {"nome": "G2", "msg": "Você: Atividade registrada.", "cor": Colors.greenAccent, "letra": "G2"},
  ];

  Color get bgMain => isDark ? const Color(0xFF1D0000) : const Color(0xFFEAFaf1);
  Color get textMain => isDark ? Colors.white : Colors.black;
  Color get pillBg => isDark ? const Color(0xFF333333) : const Color(0xFFB0B0B0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgMain,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF4A0000) : Colors.green,
        title: const Text("Mensagens Recentes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: chatsRecentes.length,
        itemBuilder: (context, index) {
          final chat = chatsRecentes[index];
          return GestureDetector(
            onTap: () {
              // Clicou na pessoa/grupo? Vai direto pro chat!
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatPage(isDark: isDark, grupoNome: chat["nome"])),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 15),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(left: 55, top: 15, bottom: 15, right: 15),
                    decoration: BoxDecoration(
                      color: pillBg,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(chat["nome"], style: TextStyle(color: textMain, fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(chat["msg"], style: TextStyle(color: textMain.withOpacity(0.7), fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  // Avatar vazando na esquerda
                  Positioned(
                    left: -10,
                    top: 8,
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: chat["cor"],
                      child: Text(chat["letra"], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}