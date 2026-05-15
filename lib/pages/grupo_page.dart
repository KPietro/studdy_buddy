import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'ranking_semanal.dart';
import 'registro_atividade.dart';
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
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: bgMain,
        color: isDark ? const Color(0xFF4A0000) : const Color(0xFF4CAF50),
        buttonBackgroundColor: isDark
            ? const Color(0xFF4A0000)
            : const Color(0xFF4CAF50),
        height: 60,
        animationDuration: const Duration(milliseconds: 300),
        index: 1,
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
              ),
            );
          }
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
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
                      String descricao =
                          tarefa['descricao'] ?? "Sem descrição.";
                      String tipoTarefa = tarefa['tipotarefa'] ?? "Comum";
                      int minutos = (tarefa['minutos'] ?? 0).toInt();
                      String pontos = "${minutos}pts";
                      String provaUrl = tarefa['urlimagem'] ?? "";
                      String nomeUsuario = tarefa['criador_nome'] ?? "?";
                      String? fotoUrl = tarefa['criador_foto'];

                      return _buildTarefaItem(
                        context,
                        titulo,
                        pontos,
                        fotoUrl,
                        nomeUsuario,
                        provaUrl: provaUrl,
                        descricao: descricao,
                        tipoTarefa: tipoTarefa,
                        minutos: minutos,
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

  Widget _buildTarefaItem(
    BuildContext context,
    String titulo,
    String pontos,
    String? fotoUrl,
    String nomeUsuario, {
    bool hasProgress = false,
    String? provaUrl,
    String descricao = "",
    String tipoTarefa = "",
    int minutos = 0,
  }) {
    return GestureDetector(
      onTap: () => _mostrarDetalhesTarefa(
        context,
        titulo,
        pontos,
        provaUrl,
        nomeUsuario,
        descricao,
        tipoTarefa,
        minutos,
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
                        nomeUsuario != "?" && nomeUsuario.isNotEmpty
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
                height: 49,
                decoration: BoxDecoration(
                  color: const Color(0xFF5A5A5A),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            titulo,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "- $pontos",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- MODAL DE DETALHES ---
  void _mostrarDetalhesTarefa(
    BuildContext context,
    String titulo,
    String pontos,
    String? provaUrl,
    String nomeUsuario,
    String descricao,
    String tipoTarefa,
    int minutos,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark
          ? const Color(0xFF2D0505)
          : const Color(0xFFEAFaf1),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
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
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildInfoRow("👤", "Feito por:", nomeUsuario),
              const SizedBox(height: 10),
              _buildInfoRow("🏷️", "Tipo:", tipoTarefa),
              const SizedBox(height: 10),
              _buildInfoRow("📌", "Ação:", titulo),
              const SizedBox(height: 10),
              _buildInfoRow("📝", "Descrição:", descricao),
              const SizedBox(height: 10),
              _buildInfoRow("⏱️", "Tempo:", "$minutos minutos"),
              const SizedBox(height: 10),
              _buildInfoRow("🏆", "Recompensa:", pontos),

              if (provaUrl != null && provaUrl.isNotEmpty) ...[
                const SizedBox(height: 25),
                const Text(
                  "📷 Comprovação (Clique para ampliar):",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    // ABRE A IMAGEM EM TELA CHEIA!
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          backgroundColor: Colors.black,
                          appBar: AppBar(
                            backgroundColor: Colors.black,
                            iconTheme: const IconThemeData(color: Colors.white),
                          ),
                          body: Center(
                            child: InteractiveViewer(
                              child: CachedNetworkImage(imageUrl: provaUrl),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl: provaUrl,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(color: Colors.green),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String emoji, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$emoji ", style: const TextStyle(fontSize: 16)),
        Text(
          "$label ",
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(value, style: TextStyle(color: textMain, fontSize: 16)),
        ),
      ],
    );
  }
}
