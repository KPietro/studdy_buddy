import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

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

  // RESPOSTA
  DocumentSnapshot? mensagemRespondendo;

  // AUDIO
  final AudioRecorder recorder = AudioRecorder();
  final AudioPlayer player = AudioPlayer();
  bool gravando = false;

  // CORES
  Color get bg =>
      widget.isDark ? const Color(0xFF0F0F0F) : const Color(0xFFEAFaf1);

  Color get txt => widget.isDark ? Colors.white : Colors.black87;

  Color get appBarColor =>
      widget.isDark ? const Color(0xFF8B0000) : Colors.green[700]!;

  Color get myMessageColor =>
      widget.isDark ? const Color(0xFF8B0000) : const Color(0xFFDCF8C6);

  Color get otherMessageColor =>
      widget.isDark ? const Color(0xFF1F1F1F) : Colors.white;

  // =========================
  // ENVIAR TEXTO
  // =========================

  Future<void> enviarMensagem() async {
    if (controller.text.trim().isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;

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
          "nome": nomeExibicao,
          "timestamp": FieldValue.serverTimestamp(),

          // RESPOSTA
          "respondendoTexto": mensagemRespondendo != null
              ? mensagemRespondendo!["texto"] ?? ""
              : "",

          "respondendoNome": mensagemRespondendo != null
              ? mensagemRespondendo!["nome"] ?? ""
              : "",

          // MIDIA
          "imagemUrl": "",
          "audioUrl": "",

          "tipo": "texto",
        });

    controller.clear();

    setState(() {
      mensagemRespondendo = null;
    });
  }

  // =========================
  // ENVIAR IMAGEM
  // =========================

  Future<void> enviarImagem() async {
    final picker = ImagePicker();

    final imagem = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (imagem == null) return;

    final user = FirebaseAuth.instance.currentUser;

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
    } catch (_) {}

    final arquivo = File(imagem.path);

    final nomeArquivo = DateTime.now().millisecondsSinceEpoch.toString();

    final ref = FirebaseStorage.instance
        .ref()
        .child("chat_imagens")
        .child(nomeArquivo);

    await ref.putFile(arquivo);

    final url = await ref.getDownloadURL();

    await FirebaseFirestore.instance
        .collection("grupos")
        .doc(widget.grupoId)
        .collection("mensagens")
        .add({
          "texto": "",
          "email": user?.email,
          "nome": nomeExibicao,
          "timestamp": FieldValue.serverTimestamp(),

          "respondendoTexto": mensagemRespondendo != null
              ? mensagemRespondendo!["texto"] ?? ""
              : "",

          "respondendoNome": mensagemRespondendo != null
              ? mensagemRespondendo!["nome"] ?? ""
              : "",

          "imagemUrl": url,
          "audioUrl": "",

          "tipo": "imagem",
        });

    setState(() {
      mensagemRespondendo = null;
    });
  }

  // =========================
  // AUDIO
  // =========================

  Future<void> gravarAudio() async {
    if (!gravando) {
      if (await recorder.hasPermission()) {
        final dir = await getTemporaryDirectory();

        final path = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.m4a';

        await recorder.start(const RecordConfig(), path: path);

        setState(() {
          gravando = true;
        });
      }
    } else {
      final path = await recorder.stop();

      setState(() {
        gravando = false;
      });

      if (path == null) return;

      final user = FirebaseAuth.instance.currentUser;

      final arquivo = File(path);

      final nome = DateTime.now().millisecondsSinceEpoch.toString();

      final ref = FirebaseStorage.instance.ref().child("audios").child(nome);

      await ref.putFile(arquivo);

      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection("grupos")
          .doc(widget.grupoId)
          .collection("mensagens")
          .add({
            "texto": "",
            "email": user?.email,
            "nome": user?.email,
            "timestamp": FieldValue.serverTimestamp(),
            "imagemUrl": "",
            "audioUrl": url,
            "tipo": "audio",
          });
    }
  }

  // =========================
  // FORMATAR HORA
  // =========================

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
  void dispose() {
    recorder.dispose();
    player.dispose();
    controller.dispose();
    super.dispose();
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
          // =========================
          // MENSAGENS
          // =========================
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
                  return const Center(child: CircularProgressIndicator());
                }

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

                    final nomeAmigavel = msg["nome"] ?? emailOrigem;

                    final timestamp = msg["timestamp"];

                    final bool minhaMensagem = emailOrigem == user?.email;

                    return GestureDetector(
                      onLongPress: () {
                        setState(() {
                          mensagemRespondendo = msg;
                        });
                      },

                      child: Align(
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

                              bottomLeft: Radius.circular(
                                minhaMensagem ? 18 : 5,
                              ),

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
                              // NOME
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
                                          : Colors.green[700],
                                    ),
                                  ),
                                ),

                              // RESPOSTA
                              if ((msg["respondendoTexto"] ?? "").isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 6),

                                  padding: const EdgeInsets.all(8),

                                  decoration: BoxDecoration(
                                    color: widget.isDark
                                        ? Colors.black26
                                        : Colors.grey.shade200,

                                    borderRadius: BorderRadius.circular(10),
                                  ),

                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      Text(
                                        msg["respondendoNome"] ?? "",

                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),

                                      Text(
                                        msg["respondendoTexto"] ?? "",

                                        maxLines: 2,

                                        overflow: TextOverflow.ellipsis,

                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),

                              // IMAGEM
                              if (msg["tipo"] == "imagem")
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),

                                  child: Image.network(
                                    msg["imagemUrl"],
                                    width: 220,
                                    fit: BoxFit.cover,
                                  ),
                                ),

                              // AUDIO
                              if (msg["tipo"] == "audio")
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),

                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,

                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.play_arrow),

                                        onPressed: () async {
                                          await player.play(
                                            UrlSource(msg["audioUrl"]),
                                          );
                                        },
                                      ),

                                      Text(
                                        "Áudio",
                                        style: TextStyle(color: txt),
                                      ),
                                    ],
                                  ),
                                ),

                              // TEXTO
                              if (msg["tipo"] == "texto")
                                Text(
                                  texto,

                                  style: TextStyle(color: txt, fontSize: 15),
                                ),

                              const SizedBox(height: 6),

                              // HORA
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
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // =========================
          // RESPONDENDO
          // =========================
          if (mensagemRespondendo != null)
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(10),

              color: widget.isDark ? Colors.black54 : Colors.green.shade50,

              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          mensagemRespondendo!["nome"] ?? "",

                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),

                        Text(
                          mensagemRespondendo!["texto"] ?? "",

                          maxLines: 1,

                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.close),

                    onPressed: () {
                      setState(() {
                        mensagemRespondendo = null;
                      });
                    },
                  ),
                ],
              ),
            ),

          // =========================
          // INPUT
          // =========================
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
                        offset: const Offset(0, -4),
                      ),
                    ],
            ),

            child: SafeArea(
              child: Row(
                children: [
                  // IMAGEM
                  IconButton(
                    icon: Icon(Icons.image, color: appBarColor),

                    onPressed: enviarImagem,
                  ),

                  // INPUT
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

                  const SizedBox(width: 6),

                  // AUDIO
                  IconButton(
                    icon: Icon(
                      gravando ? Icons.stop : Icons.mic,

                      color: gravando ? Colors.red : appBarColor,
                    ),

                    onPressed: gravarAudio,
                  ),

                  // ENVIAR
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
