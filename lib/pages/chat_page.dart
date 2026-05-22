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

  // --- CORES DO TEMA PREMIUM ---
  Color get bg => widget.isDark
      ? const Color(0xFF0F0F0F)
      : const Color(0xFFEAFaf1); // Fundo menta para combinar com resto
  Color get txt => widget.isDark ? Colors.white : Colors.black87; // Preto suave
  Color get appBarColor => widget.isDark
      ? const Color(0xFF8B0000)
      : Colors.green[700]!; // Verde Premium

  Color get myMessageColor =>
      widget.isDark ? const Color(0xFF8B0000) : const Color(0xFFDCF8C6);
  Color get otherMessageColor =>
      widget.isDark ? const Color(0xFF1F1F1F) : Colors.white;

  Future<void> enviarMensagem() async {
    if (controller.text.trim().isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;

    // Busca o nome do usuário para exibir bonito no chat em vez do e-mail cru
    String nomeExibicao = user?.email ?? "Usuário";
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user!.uid)
          .get();
      if (userDoc.exists) {
        var dados = userDoc.data() as Map<String, dynamic>;
        nomeExibicao = dados['nome_exibicao'] ?? dados['nome'] ?? nomeExibicao;
      }
    } catch (e) {
      debugPrint("Erro ao buscar nome: $e");
    }

    await FirebaseFirestore.instance
        .collection("grupos")
        .doc(widget.grupoId)
        .collection("mensagens")
        .add({
          "texto": controller.text.trim(),
          "email": user?.email ?? "Usuário",
          "nome": nomeExibicao, // Salva o nome amigável
          "timestamp": FieldValue.serverTimestamp(),
        });

    controller.clear();
  }

  String formatarHora(Timestamp? timestamp) {
    if (timestamp == null) return "";
    final data = timestamp.toDate();
    return "${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}";
  }

  String formatarData(Timestamp? timestamp) {
    if (timestamp == null) return "";
    final data = timestamp.toDate();
    return "${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}";
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: widget.isDark ? 0 : 4,
        backgroundColor: appBarColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(Icons.group, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.grupoNome,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
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
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());

                final mensagens = snapshot.data!.docs;

                if (mensagens.isEmpty) {
                  return Center(
                    child: Text(
                      "Nenhuma mensagem ainda. Diga olá!",
                      style: TextStyle(
                        color: widget.isDark ? Colors.white54 : Colors.black45,
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: mensagens.length,
                  itemBuilder: (context, index) {
                    final msg = mensagens[index];
                    final texto = msg["texto"] ?? "";
                    final emailOrigem = msg["email"] ?? "Usuário";
                    final nomeAmigavel = msg.data().toString().contains('nome')
                        ? msg["nome"]
                        : emailOrigem;
                    final timestamp = msg["timestamp"];

                    final bool minhaMensagem = emailOrigem == user?.email;

                    return Align(
                      alignment: minhaMensagem
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 320),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: minhaMensagem
                              ? myMessageColor
                              : otherMessageColor,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(18),
                            topRight: const Radius.circular(18),
                            bottomLeft: Radius.circular(minhaMensagem ? 18 : 5),
                            bottomRight: Radius.circular(
                              minhaMensagem ? 5 : 18,
                            ),
                          ),
                          boxShadow: widget.isDark
                              ? null
                              : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!minhaMensagem)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  nomeAmigavel,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: widget.isDark
                                        ? Colors.redAccent
                                        : Colors
                                              .green[700], // Verde forte no claro
                                  ),
                                ),
                              ),
                            Text(
                              texto,
                              style: TextStyle(color: txt, fontSize: 15),
                            ),
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                "${formatarHora(timestamp)} • ${formatarData(timestamp)}",
                                style: TextStyle(
                                  color: widget.isDark
                                      ? Colors.white60
                                      : Colors.black45,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // --- BARRA DE DIGITAÇÃO COM SOMBRA INVERTIDA ---
          Container(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
            decoration: BoxDecoration(
              color: widget.isDark ? const Color(0xFF151515) : Colors.white,
              boxShadow: widget.isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4), // Sombra pra cima
                      ),
                    ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.isDark
                            ? const Color(0xFF252525)
                            : const Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: widget.isDark
                              ? Colors.transparent
                              : Colors.grey.shade300,
                          width: 0.5,
                        ),
                      ),
                      child: TextField(
                        controller: controller,
                        style: TextStyle(color: txt),
                        decoration: InputDecoration(
                          hintText: "Digite uma mensagem...",
                          hintStyle: TextStyle(
                            color: widget.isDark
                                ? Colors.white54
                                : Colors.black45,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: appBarColor,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: enviarMensagem,
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
