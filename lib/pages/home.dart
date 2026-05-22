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

  // --- CORES ATUALIZADAS PARA O TEMA CLARO PREMIUM ---
  Color get bgMain =>
      isDark ? const Color(0xFF160303) : const Color(0xFFEAFaf1);
  Color get bgSidebar => isDark
      ? const Color(0xFF4A0000)
      : Colors.green[700]!; // Verde mais forte para contraste
  Color get textMain =>
      isDark ? Colors.white : Colors.black87; // Preto mais suave
  Color get pillBg => isDark
      ? const Color(0xFF333333)
      : Colors.white; // Branco puro no tema claro!

  // --- SOMBRA SUAVE PARA O TEMA CLARO ---
  List<BoxShadow>? get shadowClara => isDark
      ? null
      : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ];

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
          : Colors.white, // Modal branco no tema claro
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

  // --- DESIGN DA TAREFA ---
  Widget _buildTarefaItem(
    BuildContext context,
    String titulo,
    String? fotoUrl,
    String nomeUsuario,
    String nomeGrupo, {
    String? fotoGrupoUrl,
    String? provaUrl,
    String descricao = "",
    String tipoTarefa = "",
    int minutos = 0,
    String pontos = "0pts",
  }) {
    Color corDestaque = tipoTarefa == "Tarefa Maior"
        ? Colors.redAccent
        : Colors.greenAccent[700]!; // Verde mais forte no claro

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
          boxShadow: shadowClara, // Aplica a sombra suave aqui!
          border: tipoTarefa == "Tarefa Maior"
              ? Border.all(color: Colors.redAccent.withOpacity(0.3), width: 1)
              : null,
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  backgroundColor: isDark ? Colors.white : Colors.grey[200],
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
                        color: isDark ? const Color(0xFF160303) : Colors.white,
                        width: 1.5,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 9,
                      backgroundColor: Colors.blueGrey,
                      backgroundImage: _obterImagem(fotoGrupoUrl),
                      child: (fotoGrupoUrl == null || fotoGrupoUrl.isEmpty)
                          ? Text(
                              nomeGrupo.isNotEmpty
                                  ? nomeGrupo[0].toUpperCase()
                                  : "?",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
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
                      style: TextStyle(
                        color: isDark ? Colors.grey : Colors.grey[600],
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
                      color: isDark ? Colors.grey : Colors.grey[600],
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
                    color: corDestaque.withOpacity(isDark ? 0.2 : 0.1),
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
                                        color: isDark
                                            ? Colors.white24
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                      boxShadow:
                                          shadowClara, // Sombra suave no avatar
                                    ),
                                    child: CircleAvatar(
                                      radius: 25,
                                      backgroundColor: isDark
                                          ? Colors.white10
                                          : Colors.white,
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
                            boxShadow:
                                shadowClara, // Sombra na barra de pesquisa
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search, color: Colors.grey),
                              const SizedBox(width: 10),
                              Text(
                                "Encontrar novos grupos...",
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

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

                                String grupoId =
                                    docTarefa.reference.parent.parent!.id;

                                return FutureBuilder<DocumentSnapshot>(
                                  future: FirebaseFirestore.instance
                                      .collection('grupos')
                                      .doc(grupoId)
                                      .get(),
                                  builder: (context, grupoSnap) {
                                    String nomeGrupo = "Grupo";
                                    String? fotoGrupoDaVez;
                                    int pontosMinuto = 1;
                                    int metaMaiorBonus = 0;

                                    if (grupoSnap.hasData &&
                                        grupoSnap.data!.exists) {
                                      var dadosGrupo =
                                          grupoSnap.data!.data()
                                              as Map<String, dynamic>;
                                      nomeGrupo = dadosGrupo['nome'] ?? "Grupo";
                                      fotoGrupoDaVez = dadosGrupo['foto_grupo'];
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
                                      fotoGrupoUrl: fotoGrupoDaVez,
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
                        color: isDark ? Colors.red : Colors.green[700],
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),

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
                    child: const Icon(
                      Icons.add_circle_outline,
                      color: Colors.white,
                      size: 45,
                    ), // Ícone branco pra destacar no verde
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
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
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
                            String? fotoDoGrupo = dados['foto_grupo'];

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
                              child: _buildCardGrupo(nomeDoGrupo, fotoDoGrupo),
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
                    child: const Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Icon(
                        Icons.email_outlined,
                        color: Colors.white,
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

  Widget _buildCardGrupo(String nome, String? fotoUrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: CircleAvatar(
        backgroundColor: isDark
            ? const Color(0xFF5A5A5A)
            : Colors.white30, // Mais suave no tema claro
        radius: 25,
        backgroundImage: _obterImagem(fotoUrl),
        child: (fotoUrl == null || fotoUrl.isEmpty)
            ? Text(
                nome.isNotEmpty ? nome.substring(0, 1).toUpperCase() : "?",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
    );
  }
}
