import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'ranking_semanal.dart';
import 'registro_atividade.dart'; // Mantido para caso use a página
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

  Color get bgMain =>
      isDark ? const Color(0xFF1D0000) : const Color(0xFFEAFaf1);
  Color get textMain => isDark ? Colors.white : Colors.black;
  Color get pillBg =>
      isDark ? const Color(0xFF333333) : const Color(0xFF5A5A5A);

  // Função auxiliar para gerenciar a imagem (Cloudinary ou Assets)
  ImageProvider? _obterImagem(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http')) return CachedNetworkImageProvider(url);
    return AssetImage(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgMain,
      // --- BARRA DE NAVEGAÇÃO INFERIOR ANIMADA ---
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: bgMain,
        color: isDark ? const Color(0xFF4A0000) : const Color(0xFF4CAF50),
        buttonBackgroundColor: isDark
            ? const Color(0xFF4A0000)
            : const Color(0xFF4CAF50),
        height: 60,
        animationDuration: const Duration(milliseconds: 300),
        index: 1, // Começa no meio (Chat) por padrão visual
        items: const <Widget>[
          Icon(Icons.add_circle_outline, color: Colors.white, size: 30),
          Icon(Icons.email_outlined, color: Colors.white, size: 30),
          Icon(Icons.leaderboard_outlined, color: Colors.white, size: 30),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    RegistroAtividadePage(isDark: isDark, grupoId: grupoId),
              ),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  isDark: isDark,
                  grupoNome: grupoNome,
                  grupoId: grupoId,
                ),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RankingSemanal(grupoId: grupoId),
              ), // <-- AQUI ESTÁ A CORREÇÃO!
            );
          }
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER: BOTÃO VOLTAR E AVATAR DO GRUPO ---
            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 15,
                bottom: 5,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red[700],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  CircleAvatar(
                    backgroundColor: Colors.greenAccent[700],
                    radius: 22,
                    child: Text(
                      grupoNome.isNotEmpty ? grupoNome[0].toUpperCase() : "G",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      grupoNome,
                      style: TextStyle(
                        color: textMain,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // --- BARRA DE PESQUISA ---
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 15.0,
              ),
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFF5A5A5A),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Pesquisar tarefas...",
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                    suffixIcon: Icon(Icons.search, color: Colors.white),
                  ),
                ),
              ),
            ),

            // --- LISTA DE TAREFAS DINÂMICA DO FIREBASE ---
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('grupos')
                    .doc(grupoId)
                    .collection('tarefas')
                    .orderBy('data_criacao', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        "Nenhuma atividade registrada ainda.",
                        style: TextStyle(color: textMain),
                      ),
                    );
                  }

                  var tarefas = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: tarefas.length,
                    itemBuilder: (context, index) {
                      var tarefa =
                          tarefas[index].data() as Map<String, dynamic>;

                      String titulo = tarefa['acao'] ?? "Atividade";
                      String pontos = "${tarefa['minutos'] ?? 0}pts";
                      String criadorId = tarefa['criador_id'] ?? "";
                      String provaUrl = tarefa['urlimagem'] ?? "";

                      // FutureBuilder para buscar a foto e o nome de quem fez a tarefa
                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('usuarios')
                            .doc(criadorId)
                            .get(),
                        builder: (context, userSnap) {
                          String nomeUsuario = "?";
                          String? fotoUrl;

                          if (userSnap.hasData && userSnap.data!.exists) {
                            var userData =
                                userSnap.data!.data() as Map<String, dynamic>;
                            nomeUsuario =
                                userData['nome_exibicao'] ??
                                userData['nome'] ??
                                "?";
                            fotoUrl = userData['url_perfil'];
                          }

                          return _buildTarefaItem(
                            context,
                            titulo,
                            pontos,
                            fotoUrl,
                            nomeUsuario,
                            provaUrl: provaUrl,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET DA TAREFA ATUALIZADO ---
  Widget _buildTarefaItem(
    BuildContext context,
    String titulo,
    String pontos,
    String? fotoUrl,
    String nomeUsuario, {
    bool hasProgress = false,
    String? provaUrl,
  }) {
    return GestureDetector(
      onTap: () => _mostrarDetalhesTarefa(
        context,
        titulo,
        pontos,
        provaUrl,
        nomeUsuario,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20,
              child: CircleAvatar(
                backgroundColor: Colors.green[800],
                radius: 18,
                backgroundImage: _obterImagem(fotoUrl),
                child: (fotoUrl == null || fotoUrl.isEmpty)
                    ? Text(
                        nomeUsuario.isNotEmpty
                            ? nomeUsuario[0].toUpperCase()
                            : "?",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Container(
                height: 49, // Aumentado em 4 pixels (era 45)
                decoration: BoxDecoration(
                  color: const Color(0xFF5A5A5A),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Stack(
                  children: [
                    if (hasProgress)
                      Positioned(
                        left: 15,
                        right: 40,
                        bottom: 8,
                        child: Container(height: 3, color: Colors.blue),
                      ),
                    // Textos Centralizados
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                titulo,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      19, // Aumentado em 6 pixels (era 13)
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "- $pontos",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18, // Aumentado em 6 pixels (era 12)
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- MODAL DE DETALHES ATUALIZADO (AGORA MOSTRA A FOTO!) ---
  void _mostrarDetalhesTarefa(
    BuildContext context,
    String titulo,
    String pontos,
    String? provaUrl,
    String nomeUsuario,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark
          ? const Color(0xFF2D0505)
          : const Color(0xFFEAFaf1),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true, // Permite que o modal fique maior se tiver foto
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Detalhes da Atividade",
                style: TextStyle(
                  color: textMain,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                "👤 Feito por: $nomeUsuario",
                style: TextStyle(color: textMain, fontSize: 16),
              ),
              const SizedBox(height: 5),
              Text(
                "📌 Atividade: $titulo",
                style: TextStyle(color: textMain, fontSize: 16),
              ),
              const SizedBox(height: 5),
              Text(
                "🏆 Recompensa: $pontos",
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // SE TIVER FOTO, ELA APARECE AQUI!
              if (provaUrl != null && provaUrl.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text(
                  "📷 Comprovação:",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: CachedNetworkImage(
                    imageUrl: provaUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(color: Colors.green),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 150,
                      color: Colors.black26,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.wifi_off, color: Colors.grey, size: 40),
                          Text(
                            "Imagem indisponível offline",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[800],
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _abrirModalQuestionamento(context);
                  },
                  icon: const Icon(Icons.gavel, color: Colors.white),
                  label: const Text(
                    "Questionar Tarefa",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _abrirModalQuestionamento(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1D0000) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 25,
            left: 25,
            right: 25,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.amber,
                    size: 30,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Questionar Atividade",
                    style: TextStyle(
                      color: textMain,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF333333) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey),
                ),
                child: TextField(
                  maxLines: 3,
                  style: TextStyle(color: textMain),
                  decoration: const InputDecoration(
                    hintText: "Descreva o motivo da suspeita...",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(15),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[700],
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Questionamento enviado aos líderes!"),
                      ),
                    );
                  },
                  child: const Text(
                    "Enviar para Análise",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
