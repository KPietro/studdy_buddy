import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/imagem_controller.dart'; // <-- Para editar a foto
import 'ranking_semanal.dart';
import 'registro_atividade.dart';
import 'chat_page.dart';

class GrupoPage extends StatefulWidget {
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
  State<GrupoPage> createState() => _GrupoPageState();
}

class _GrupoPageState extends State<GrupoPage> {
  int ptsPorMinuto = 1;
  int metaMaiorBonus = 0;

  @override
  void initState() {
    super.initState();
    _carregarRegrasESincronizar();
  }

  Future<void> _carregarRegrasESincronizar() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      var grupoDoc = await FirebaseFirestore.instance
          .collection('grupos')
          .doc(widget.grupoId)
          .get();
      if (grupoDoc.exists) {
        var dados = grupoDoc.data() as Map<String, dynamic>;
        setState(() {
          ptsPorMinuto =
              (dados['pontos_por_minuto'] ?? dados['pontos_minuto'] ?? 1)
                  .toInt();
          metaMaiorBonus =
              (dados['pontos_meta_maior'] ?? dados['meta_maior'] ?? 0).toInt();
        });
      }

      var userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();
      if (!userDoc.exists) return;
      var userData = userDoc.data() as Map<String, dynamic>;
      String nomeAtual =
          userData['nome_exibicao'] ?? userData['nome'] ?? "Usuário";
      String fotoAtual = userData['url_perfil'] ?? "";

      var membroRef = FirebaseFirestore.instance
          .collection('grupos')
          .doc(widget.grupoId)
          .collection('membros')
          .doc(user.uid);
      var membroDoc = await membroRef.get();

      bool precisaAtualizar = false;
      if (membroDoc.exists) {
        var membroData = membroDoc.data() as Map<String, dynamic>;
        if (membroData['fotoPerfil'] != fotoAtual ||
            membroData['nome'] != nomeAtual)
          precisaAtualizar = true;
      } else {
        precisaAtualizar = true;
      }

      if (precisaAtualizar) {
        await membroRef.update({'fotoPerfil': fotoAtual, 'nome': nomeAtual});
        var tarefasQuery = await FirebaseFirestore.instance
            .collection('grupos')
            .doc(widget.grupoId)
            .collection('tarefas')
            .where('criador_id', isEqualTo: user.uid)
            .get();
        if (tarefasQuery.docs.isNotEmpty) {
          var batch = FirebaseFirestore.instance.batch();
          for (var doc in tarefasQuery.docs)
            batch.update(doc.reference, {
              'criador_nome': nomeAtual,
              'criador_foto': fotoAtual,
            });
          await batch.commit();
        }
      }
    } catch (e) {
      debugPrint("Erro ao sincronizar dados: $e");
    }
  }

  // --- NOVA FUNÇÃO: Trocar a foto do Grupo ---
  Future<void> _trocarFotoGrupo() async {
    String? link = await ImagemController.escolherESubirImagem();
    if (link != null) {
      await FirebaseFirestore.instance
          .collection('grupos')
          .doc(widget.grupoId)
          .update({'foto_grupo': link});
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Foto do grupo atualizada!")),
        );
    }
  }

  // --- CORES ATUALIZADAS PARA O TEMA CLARO PREMIUM ---
  Color get bgMain =>
      widget.isDark ? const Color(0xFF1D0000) : const Color(0xFFEAFaf1);
  Color get textMain => widget.isDark ? Colors.white : Colors.black87;
  Color get pillBg => widget.isDark ? const Color(0xFF333333) : Colors.white;

  List<BoxShadow>? get shadowClara => widget.isDark
      ? null
      : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ];

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
        color: widget.isDark
            ? const Color(0xFF4A0000)
            : Colors.green[700]!, // Verde forte no menu
        buttonBackgroundColor: widget.isDark
            ? const Color(0xFF4A0000)
            : Colors.green[700]!,
        height: 60,
        animationDuration: const Duration(milliseconds: 300),
        index: 1,
        items: const <Widget>[
          Icon(Icons.add_circle_outline, color: Colors.white, size: 30),
          Icon(Icons.email_outlined, color: Colors.white, size: 30),
          Icon(Icons.leaderboard_outlined, color: Colors.white, size: 30),
        ],
        onTap: (index) {
          if (index == 0)
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RegistroAtividadePage(
                  isDark: widget.isDark,
                  grupoId: widget.grupoId,
                ),
              ),
            );
          else if (index == 1)
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  isDark: widget.isDark,
                  grupoNome: widget.grupoNome,
                  grupoId: widget.grupoId,
                ),
              ),
            );
          else if (index == 2)
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RankingSemanal(grupoId: widget.grupoId),
              ),
            );
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER COM FOTO DO GRUPO EM TEMPO REAL ---
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('grupos')
                  .doc(widget.grupoId)
                  .snapshots(),
              builder: (context, snapshot) {
                String fotoGrupo = "";
                String nomeAtualizado = widget.grupoNome;

                if (snapshot.hasData && snapshot.data!.exists) {
                  var dados = snapshot.data!.data() as Map<String, dynamic>;
                  fotoGrupo = dados['foto_grupo'] ?? "";
                  nomeAtualizado = dados['nome'] ?? widget.grupoNome;
                }

                return Padding(
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

                      // AVATAR EDITÁVEL DO GRUPO
                      GestureDetector(
                        onTap: _trocarFotoGrupo,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: shadowClara,
                              ),
                              child: CircleAvatar(
                                backgroundColor: widget.isDark
                                    ? Colors.greenAccent[700]
                                    : Colors.green[700],
                                radius: 22,
                                backgroundImage: _obterImagem(fotoGrupo),
                                child: (fotoGrupo.isEmpty)
                                    ? Text(
                                        nomeAtualizado.isNotEmpty
                                            ? nomeAtualizado[0].toUpperCase()
                                            : "G",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: -2,
                              right: -2,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 0.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  size: 12,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          nomeAtualizado,
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
                );
              },
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 15.0,
              ),
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: pillBg, // Ficou branco no tema claro!
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: shadowClara,
                ),
                child: TextField(
                  style: TextStyle(color: textMain),
                  decoration: InputDecoration(
                    hintText: "Pesquisar tarefas...",
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                    suffixIcon: const Icon(Icons.search, color: Colors.grey),
                  ),
                ),
              ),
            ),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('grupos')
                    .doc(widget.grupoId)
                    .collection('tarefas')
                    .orderBy('data_criacao', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return const Center(child: CircularProgressIndicator());
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                    return Center(
                      child: Text(
                        "Nenhuma atividade registrada ainda.",
                        style: TextStyle(color: textMain),
                      ),
                    );

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

                      int totalPontosCalculados =
                          (minutos * ptsPorMinuto) +
                          (tipoTarefa == "Tarefa Maior" ? metaMaiorBonus : 0);
                      String pontos = "${totalPontosCalculados}pts";

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
    Color corDestaque = tipoTarefa == "Tarefa Maior"
        ? Colors.redAccent
        : Colors.green[700]!;

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
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: pillBg,
          borderRadius: BorderRadius.circular(15),
          boxShadow: shadowClara, // Sombrinha suave nas tarefas
          border: tipoTarefa == "Tarefa Maior"
              ? Border.all(color: Colors.redAccent.withOpacity(0.3), width: 1)
              : null,
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: widget.isDark ? Colors.white : Colors.grey[200],
              radius: 22,
              child: CircleAvatar(
                backgroundColor: Colors.green[800],
                radius: 20,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      color: textMain,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (descricao.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      descricao,
                      style: TextStyle(
                        color: widget.isDark ? Colors.grey : Colors.grey[600],
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    "$minutos minutos",
                    style: TextStyle(
                      color: widget.isDark ? Colors.grey : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  pontos,
                  style: TextStyle(
                    color: corDestaque,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: corDestaque.withOpacity(widget.isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tipoTarefa == "Tarefa Maior" ? "Maior" : "Comum",
                    style: TextStyle(
                      color: corDestaque,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

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
      backgroundColor: widget.isDark
          ? const Color(0xFF2D0505)
          : Colors.white, // Modal branco no tema claro!
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
                  onTap: () => Navigator.push(
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
                  ),
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
