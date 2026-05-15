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
import 'explorar_grupos.dart'; // <-- IMPORT DA PÁGINA NOVA!

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgMain,
      body: SafeArea(
        child: Row(
          children: [
            // 🔹 ÁREA PRINCIPAL (ESQUERDA)
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
                            // ÍCONE DE PERFIL DINÂMICO
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

                      // BARRA DE PESQUISA (ABRE A TELA EXPLORAR GRUPOS)
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

                      // TÍTULO "MINHAS ATIVIDADES RECENTES"
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

                      // 📋 LISTA DE TAREFAS RECENTES DO USUÁRIO
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collectionGroup('tarefas')
                              .where('criador_id', isEqualTo: user?.uid)
                              .orderBy('data_criacao', descending: true)
                              .limit(15)
                              .snapshots(),
                          builder: (context, snapshot) {
                            // AQUI ESTÁ A MÁGICA: Vai mostrar o erro e o link na tela!
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
                                var tarefa =
                                    tarefas[index].data()
                                        as Map<String, dynamic>;
                                String acao = tarefa['acao'] ?? "Atividade";
                                int minutos = tarefa['minutos'] ?? 0;
                                String tipo = tarefa['tipotarefa'] ?? "Comum";

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: pillBg,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: tipo == "Tarefa Maior"
                                            ? Colors.amber
                                            : Colors.blueAccent,
                                        child: Icon(
                                          tipo == "Tarefa Maior"
                                              ? Icons.workspace_premium
                                              : Icons.check,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              acao,
                                              style: TextStyle(
                                                color: textMain,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              "$minutos minutos investidos",
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  // ⚙️ ENGRENAGEM (CONFIGURAÇÕES)
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

            // 🔹 SIDEBAR (DIREITA) - MEUS GRUPOS MANTIDA IGUAL
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
