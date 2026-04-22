import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final bool isDark;
  final String grupoNome;

  const ChatPage({super.key, required this.isDark, required this.grupoNome});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Color get bgMain => widget.isDark ? const Color(0xFF1D0000) : const Color(0xFFEAFaf1);
  Color get textMain => widget.isDark ? Colors.white : Colors.black;
  Color get pillBg => widget.isDark ? const Color(0xFF333333) : Colors.white;

  final TextEditingController _msgController = TextEditingController();

  final List<Map<String, dynamic>> mensagens = [
    {"nome": "Pietro", "msg": "E aí galera, bora fechar aquele simulado hoje?", "hora": "14:30", "cor": Colors.green},
    {"nome": "Mari", "msg": "Bora! Eu já fiz a parte de matemática.", "hora": "14:32", "cor": Colors.purple},
    {"nome": "Brayan", "msg": "Vou entrar as 15h, me esperem", "hora": "14:35", "cor": Colors.blue},
    {"nome": "Tim", "msg": "Tranquilo, eu to revisando história enquanto isso.", "hora": "14:36", "cor": Colors.orange},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgMain,
      appBar: AppBar(
        backgroundColor: widget.isDark ? const Color(0xFF4A0000) : Colors.green,
        title: Text("Chat - ${widget.grupoNome}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: mensagens.length,
              itemBuilder: (context, index) {
                final m = mensagens[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: m["cor"],
                        radius: 20,
                        child: Text(m["nome"][0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(m["nome"], style: TextStyle(color: m["cor"], fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(width: 10),
                                Text(m["hora"], style: TextStyle(color: textMain.withOpacity(0.5), fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(m["msg"], style: TextStyle(color: textMain, fontSize: 15)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: widget.isDark ? const Color(0xFF2D0505) : Colors.white, 
              border: Border(top: BorderSide(color: widget.isDark ? Colors.red.withOpacity(0.3) : Colors.green.withOpacity(0.3))),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: pillBg,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.grey.withOpacity(0.5)),
                      ),
                      child: TextField(
                        controller: _msgController,
                        style: TextStyle(color: textMain),
                        decoration: InputDecoration(
                          hintText: "Conversar em #${widget.grupoNome}",
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    backgroundColor: widget.isDark ? Colors.red[700] : Colors.green,
                    radius: 24,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () {
                        if (_msgController.text.isNotEmpty) {
                          setState(() {
                            mensagens.add({
                              "nome": "Pietro",
                              "msg": _msgController.text,
                              "hora": "Agora",
                              "cor": Colors.greenAccent[700],
                            });
                            _msgController.clear();
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}