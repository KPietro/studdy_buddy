import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PrivateChatPage extends StatefulWidget {
  final String nomeDestino;
  final String uidDestino;

  const PrivateChatPage({
    super.key,
    required this.nomeDestino,
    required this.uidDestino,
  });

  @override
  State<PrivateChatPage> createState() => _PrivateChatPageState();
}

class _PrivateChatPageState extends State<PrivateChatPage> {
  final TextEditingController controller = TextEditingController();

  String get chatId {
    final meuUid = FirebaseAuth.instance.currentUser!.uid;

    List ids = [meuUid, widget.uidDestino];
    ids.sort();

    return "${ids[0]}_${ids[1]}";
  }

  Future enviar() async {
    if (controller.text.trim().isEmpty) return;

    await FirebaseFirestore.instance
        .collection("chats_privados")
        .doc(chatId)
        .collection("mensagens")
        .add({
      "uid": FirebaseAuth.instance.currentUser!.uid,
      "texto": controller.text.trim(),
      "hora": FieldValue.serverTimestamp(),
    });

    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nomeDestino),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("chats_privados")
                  .doc(chatId)
                  .collection("mensagens")
                  .orderBy("hora")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final msgs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: msgs.length,
                  itemBuilder: (context, i) {
                    final msg = msgs[i];

                    return ListTile(
                      title: Text(msg["texto"]),
                    );
                  },
                );
              },
            ),
          ),

          Row(
            children: [
              Expanded(
                child: TextField(controller: controller),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: enviar,
              )
            ],
          )
        ],
      ),
    );
  }
}
