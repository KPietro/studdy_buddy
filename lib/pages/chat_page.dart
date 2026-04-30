import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatefulWidget {
  final bool isDark;
  final String grupoNome;
  final String grupoId;

  const ChatPage({
    super.key,
    required this.isDark,
    required this.grupoNome,
    required this.grupoId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController controller = TextEditingController();

  Color get bg =>
      widget.isDark ? const Color(0xFF1D0000) : const Color(0xFFEAFaf1);

  Color get txt =>
      widget.isDark ? Colors.white : Colors.black;

  Future<void> enviarMensagem() async {
    if (controller.text.trim().isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    final agora = DateTime.now();

    String data =
        "${agora.day.toString().padLeft(2, '0')}/"
        "${agora.month.toString().padLeft(2, '0')}/"
        "${agora.year}";

    String hora =
        "${agora.hour.toString().padLeft(2, '0')}:"
        "${agora.minute.toString().padLeft(2, '0')}";

    await FirebaseFirestore.instance
        .collection("grupos")
        .doc(widget.grupoId)
        .collection("mensagens")
        .add({
      "texto":
          "[$data, $hora] ${user?.email ?? "Usuário"} - ${controller.text.trim()}",
      "timestamp": FieldValue.serverTimestamp(),
    });

    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,

      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(widget.grupoNome),
      ),

      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("grupos")
                  .doc(widget.grupoId)
                  .collection("mensagens")
                  .orderBy("timestamp")
                  .snapshots(),

              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final mensagens = snapshot.data!.docs;

                if (mensagens.isEmpty) {
                  return Center(
                    child: Text(
                      "Nenhuma mensagem ainda",
                      style: TextStyle(color: txt),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: mensagens.length,

                  itemBuilder: (context, index) {
                    final msg = mensagens[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),

                      decoration: BoxDecoration(
                        color: widget.isDark
                            ? const Color(0xFF2D0505)
                            : Colors.white,
                        borderRadius:
                            BorderRadius.circular(15),
                      ),

                      child: Text(
                        msg["texto"],
                        style: TextStyle(
                          color: txt,
                          fontSize: 15,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white,

            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: "Digite mensagem...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                IconButton(
                  icon: const Icon(Icons.send),
                  color: Colors.green,
                  onPressed: enviarMensagem,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
