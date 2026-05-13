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

class HomePage extends StatefulWidget {
  final bool isDark;

  const HomePage({super.key, required this.isDark});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late bool isDark;
  String queryPesquisa = ""; // Variável para controlar a pesquisa
  final user = FirebaseAuth.instance.currentUser; // Usuário atual

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

  // --- NOVA FUNÇÃO: ENTRAR NO GRUPO ---
  Future<void> _entrarNoGrupo(String grupoId) async {
    if (user == null) return;

    try {
      // 1. Busca os dados do usuário para colocar no ranking do grupo
      var userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user!.uid)
          .get();
      String nomeExibicao = "Usuário";
      String fotoUrl = "";

      if (userDoc.exists) {
        var dados = userDoc.data() as Map<String, dynamic>;
        nomeExibicao = dados['nome_exibicao'] ?? dados['nome'] ?? "Usuário";
        fotoUrl = dados['url_perfil'] ?? "";
      }

      // 2. Adiciona o usuário na subcoleção 'membros' do grupo
      await FirebaseFirestore.instance
          .collection('grupos')
          .doc(grupoId)
          .collection('membros')
          .doc(user!.uid)
          .set({
            'nome': nomeExibicao,
            'fotoPerfil': fotoUrl,
            'pontosSemanais': 0,
            'pontosTotais': 0,
            'atividadesMaioresSemanais': 0,
            'atividadesMaioresTotais': 0,
            'cargo': 'membro',
            'data_entrada': FieldValue.serverTimestamp(),
          });

      // 3. Atualiza o array 'membros_ids' no documento do grupo para ele aparecer na barra lateral
      await FirebaseFirestore.instance.collection('grupos').doc(grupoId).update(
        {
          'membros_ids': FieldValue.arrayUnion([user!.uid]),
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Você entrou no grupo com sucesso!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erro ao entrar no grupo."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgMain,
      body: SafeArea(
        child: Row(
          children: [
            // 🔹 ÁREA PRINCIPAL (ESQUERDA) - EXPLORAR GRUPOS
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

                      // TÍTULO "EXPLORAR" E BARRA DE PESQUISA
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "Explorar Grupos",
                          style: TextStyle(
                            color: textMain,
                            fontSize: 26,
                            fontFamily: 'Comic Sans MS',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextField(
                          style: TextStyle(color: textMain),
                          onChanged: (valor) {
                            setState(() {
                              queryPesquisa = valor;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: "Buscar por nome...",
                            hintStyle: const TextStyle(color: Colors.grey),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.grey,
                            ),
                            filled: true,
                            fillColor: pillBg,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 📋 LISTA DE GRUPOS (EXPLORAR)
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: queryPesquisa.isEmpty
                              ? FirebaseFirestore.instance
                                    .collection('grupos')
                                    .orderBy(
                                      'data_criacao',
                                      descending: false,
                                    ) // Se não pesquisar, mostra os mais antigos/sugeridos
                                    .limit(30)
                                    .snapshots()
                              : FirebaseFirestore.instance
                                    .collection('grupos')
                                    .where(
                                      'nome',
                                      isGreaterThanOrEqualTo: queryPesquisa,
                                    )
                                    .where(
                                      'nome',
                                      isLessThan: queryPesquisa + 'z',
                                    )
                                    .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting)
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty)
                              return Center(
                                child: Text(
                                  "Nenhum grupo encontrado.",
                                  style: TextStyle(color: textMain),
                                ),
                              );

                            var gruposDescobrir = snapshot.data!.docs;

                            return ListView.builder(
                              padding: const EdgeInsets.only(
                                left: 20,
                                right: 20,
                                bottom: 80,
                              ),
                              itemCount: gruposDescobrir.length,
                              itemBuilder: (context, index) {
                                var dados =
                                    gruposDescobrir[index].data()
                                        as Map<String, dynamic>;
                                String idDoGrupo = gruposDescobrir[index].id;
                                String nomeDoGrupo =
                                    dados['nome'] ?? "Sem nome";
                                List membrosIds = dados['membros_ids'] ?? [];
                                int qtdMembros = membrosIds.length;

                                // Verifica se o usuário atual já está neste grupo
                                bool jaParticipa =
                                    user != null &&
                                    membrosIds.contains(user!.uid);

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 15),
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: pillBg,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor:
                                            Colors.greenAccent[700],
                                        radius: 25,
                                        child: Text(
                                          nomeDoGrupo.isNotEmpty
                                              ? nomeDoGrupo[0].toUpperCase()
                                              : "?",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              nomeDoGrupo,
                                              style: TextStyle(
                                                color: textMain,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              "$qtdMembros membro(s)",
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),

                                      // BOTÃO DE ENTRAR OU AVISO "JÁ PARTICIPA"
                                      jaParticipa
                                          ? const Text(
                                              "Participando",
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            )
                                          : ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: isDark
                                                    ? Colors.red[700]
                                                    : Colors.green,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 15,
                                                      vertical: 0,
                                                    ),
                                              ),
                                              onPressed: () =>
                                                  _entrarNoGrupo(idDoGrupo),
                                              child: const Text(
                                                "Entrar",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
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

            // 🔹 SIDEBAR (DIREITA) - MEUS GRUPOS
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

                  // 📋 LISTA DOS MEUS GRUPOS INDIVIDUAIS
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      // A MÁGICA: Só puxa grupos onde o seu UID está na lista 'membros_ids'
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

                  // Ícone de Mensagem
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
