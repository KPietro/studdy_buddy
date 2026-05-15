import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/theme_controller.dart';
import 'criacao_grupo.dart';
import 'chats_recentes.dart';
import 'grupo_page.dart';
import 'perfil.dart';
import 'config_page.dart';
import 'explorar_grupos.dart';

class HomePage extends StatefulWidget {
  final bool isDark;

  const HomePage({super.key, required this.isDark});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late bool isDark;
  final user = FirebaseAuth.instance.currentUser;

  ImageProvider? _obterImagem(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http')) return CachedNetworkImageProvider(url);
    return AssetImage(url);
  }

  @override
  void initState() {
    super.initState();
    isDark = widget.isDark;
  }

  Color get bgMain =>
      isDark ? const Color(0xFF160303) : const Color(0xFFEAFaf1);
  Color get bgSidebar =>
      isDark ? const Color(0xFF4A0000) : const Color(0xFF4CAF50);
  Color get textMain => isDark ? Colors.white : Colors.black;
  Color get pillBg =>
      isDark ? const Color(0xFF333333) : const Color(0xFFB0B0B0);

  // --- MODAL DE DETALHES DA TAREFA ---
  void _mostrarDetalhesTarefa(
    BuildContext context,
    String titulo,
    String pontos,
    String? provaUrl,
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
              _buildInfoRow("👤", "Feito por:", "Você"),
              const SizedBox(height: 10),
              _buildInfoRow("🏷️", "Tipo:", tipoTarefa),
              const SizedBox(height: 10),
              _buildInfoRow("📌", "Ação:", titulo),
              const SizedBox(height: 10),
              _buildInfoRow(
                "📝",
                "Descrição:",
                descricao.isEmpty ? "Sem descrição." : descricao,
              ),
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

  // --- DESIGN DA TAREFA COM MINI FOTO DO GRUPO NO CANTO SUPERIOR ESQUERDO ---
  Widget _buildTarefaItem(
    BuildContext context,
    String titulo,
    String? fotoUrl,
    String nomeUsuario,
    String nomeGrupo, {
    String? provaUrl,
    String descricao = "",
    String tipoTarefa = "",
    int minutos = 0,
    String pontos = "0pts",
  }) {
    Color corDestaque = tipoTarefa == "Tarefa Maior"
        ? Colors.redAccent
        : Colors.greenAccent[400]!;

    return GestureDetector(
      onTap: () => _mostrarDetalhesTarefa(
        context,
        titulo,
        pontos,
        provaUrl,
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
          border: tipoTarefa == "Tarefa Maior"
              ? Border.all(color: Colors.redAccent.withOpacity(0.3), width: 1)
              : null,
        ),
        child: Row(
          children: [
            // Avatar do criador com um mini distintivo do grupo no canto superior esquerdo
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 22,
                  child: CircleAvatar(
                    backgroundColor: Colors.green[800],
                    radius: 20,
                    backgroundImage: _obterImagem(fotoUrl),
                    child: (fotoUrl == null || fotoUrl.isEmpty)
                        ? Text(
                            nomeUsuario != "?" && nomeUsuario.isNotEmpty
                                ? nomeUsuario[0].toUpperCase()
                                : "V",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                ),
                Positioned(
                  left: -6,
                  top: -6,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF160303)
                            : const Color(0xFFEAFaf1),
                        width: 1.5,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 9,
                      backgroundColor: Colors.blueGrey,
                      child: Text(
                        nomeGrupo.isNotEmpty ? nomeGrupo[0].toUpperCase() : "?",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    "$minutos minutos",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Destaque de pontos na direita idêntico ao grupo_page
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
                    color: corDestaque.withOpacity(0.2),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgMain,
      body: SafeArea(
        child: Row(
          children: [
            // AREA PRINCIPAL (ESQUERDA)
            Expanded(
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            const SizedBox(height: 50),
                            // ICONE DE PERFIL DINAMICO
                            StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('usuarios')
                                  .doc(user?.uid)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                String? fotoUrl;
                                String inicial = "P";

                                if (snapshot.hasData && snapshot.data!.exists) {
                                  var dados =
                                      snapshot.data!.data()
                                          as Map<String, dynamic>;
                                  fotoUrl = dados['url_perfil'];
                                  String nome =
                                      dados['nome_exibicao'] ??
                                      dados['nome'] ??
                                      "";
                                  if (nome.isNotEmpty)
                                    inicial = nome[0].toUpperCase();
                                }

                                return GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const PerfilPage(),
                                    ),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white24,
                                        width: 2,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: 25,
                                      backgroundColor: isDark
                                          ? Colors.white10
                                          : Colors.black12,
                                      backgroundImage: _obterImagem(fotoUrl),
                                      child:
                                          (fotoUrl == null || fotoUrl.isEmpty)
                                          ? Text(
                                              inicial,
                                              style: TextStyle(
                                                color: textMain,
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          : null,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // BARRA DE PESQUISA
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ExplorarGruposPage(isDark: isDark),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: pillBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search, color: Colors.grey),
                              const SizedBox(width: 10),
                              Text(
                                "Encontrar novos grupos...",
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // TITULO "MINHAS ATIVIDADES RECENTES"
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "Atividades Recentes",
                          style: TextStyle(
                            color: textMain,
                            fontSize: 24,
                            fontFamily: 'Comic Sans MS',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // LISTA DE TAREFAS RECENTES DO USUARIO
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collectionGroup('tarefas')
                              .where('criador_id', isEqualTo: user?.uid)
                              .orderBy('data_criacao', descending: true)
                              .limit(15)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: SelectableText(
                                    "Falta criar o Índice! Copie este link e cole no navegador:\n\n${snapshot.error}",
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting)
                              return const Center(
                                child: CircularProgressIndicator(),
                              );

                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return Center(
                                child: Text(
                                  "Você ainda não registrou nenhuma atividade.",
                                  style: TextStyle(color: textMain),
                                ),
                              );
                            }

                            var tarefas = snapshot.data!.docs;

                            return ListView.builder(
                              padding: const EdgeInsets.only(
                                left: 20,
                                right: 20,
                                bottom: 80,
                              ),
                              itemCount: tarefas.length,
                              itemBuilder: (context, index) {
                                var docTarefa = tarefas[index];
                                var tarefa =
                                    docTarefa.data() as Map<String, dynamic>;

                                String acao = tarefa['acao'] ?? "Atividade";
                                String descricao = tarefa['descricao'] ?? "";
                                int minutos = (tarefa['minutos'] ?? 0).toInt();
                                String tipo = tarefa['tipotarefa'] ?? "Comum";
                                String provaUrl = tarefa['urlimagem'] ?? "";
                                String nomeUsuario =
                                    tarefa['criador_nome'] ?? "Você";
                                String? fotoUrl = tarefa['criador_foto'];

                                // Pega o ID do grupo pai na rota das subcoleções
                                String grupoId =
                                    docTarefa.reference.parent.parent!.id;

                                // FutureBuilder para obter as regras de cálculo e nome de cada grupo específico
                                return FutureBuilder<DocumentSnapshot>(
                                  future: FirebaseFirestore.instance
                                      .collection('grupos')
                                      .doc(grupoId)
                                      .get(),
                                  builder: (context, grupoSnap) {
                                    String nomeGrupo = "Grupo";
                                    int pontosMinuto = 1;
                                    int metaMaiorBonus = 0;

                                    if (grupoSnap.hasData &&
                                        grupoSnap.data!.exists) {
                                      var dadosGrupo =
                                          grupoSnap.data!.data()
                                              as Map<String, dynamic>;
                                      nomeGrupo = dadosGrupo['nome'] ?? "Grupo";
                                      pontosMinuto =
                                          (dadosGrupo['pontos_por_minuto'] ??
                                                  dadosGrupo['pontos_minuto'] ??
                                                  1)
                                              .toInt();
                                      metaMaiorBonus =
                                          (dadosGrupo['pontos_meta_maior'] ??
                                                  dadosGrupo['meta_maior'] ??
                                                  0)
                                              .toInt();
                                    }

                                    // Calcula os pontos em tempo real baseado no grupo de origem da tarefa
                                    int totalPontosCalculados =
                                        (minutos * pontosMinuto) +
                                        (tipo == "Tarefa Maior"
                                            ? metaMaiorBonus
                                            : 0);
                                    String pontos =
                                        "${totalPontosCalculados}pts";

                                    return _buildTarefaItem(
                                      context,
                                      acao,
                                      fotoUrl,
                                      nomeUsuario,
                                      nomeGrupo,
                                      provaUrl: provaUrl,
                                      descricao: descricao,
                                      tipoTarefa: tipo,
                                      minutos: minutos,
                                      pontos: pontos,
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

                  // ENGRENAGEM (CONFIGURACOES)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ConfigPage(),
                        ),
                      ),
                      child: Icon(
                        Icons.settings,
                        color: isDark ? Colors.red : Colors.greenAccent,
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // SIDEBAR (DIREITA) - MEUS GRUPOS MANTIDA IGUAL
            Container(
              width: 70,
              decoration: BoxDecoration(
                color: bgSidebar,
                border: Border(
                  left: BorderSide(
                    color: isDark ? Colors.red.shade900 : Colors.green.shade800,
                    width: 2,
                  ),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CriacaoGrupoPage(isDark: isDark),
                      ),
                    ),
                    child: Icon(
                      Icons.add_circle_outline,
                      color: textMain,
                      size: 45,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Divider(color: Colors.white54, thickness: 1),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('grupos')
                          .where('membros_ids', arrayContains: user?.uid ?? '')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData)
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        var meusGrupos = snapshot.data!.docs;
                        return ListView.builder(
                          itemCount: meusGrupos.length,
                          itemBuilder: (context, index) {
                            var dados =
                                meusGrupos[index].data()
                                    as Map<String, dynamic>;
                            String idDoGrupo = meusGrupos[index].id;
                            String nomeDoGrupo = dados['nome'] ?? "Sem nome";
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => GrupoPage(
                                      isDark: isDark,
                                      grupoNome: nomeDoGrupo,
                                      grupoId: idDoGrupo,
                                    ),
                                  ),
                                );
                              },
                              child: _buildCardGrupo(nomeDoGrupo),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatsRecentesPage(isDark: isDark),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Icon(
                        Icons.email_outlined,
                        color: textMain,
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardGrupo(String nome) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        color: const Color(0xFF5A5A5A),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(
        child: Text(
          nome.isNotEmpty ? nome.substring(0, 1).toUpperCase() : "?",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
