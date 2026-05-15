import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ExplorarGruposPage extends StatefulWidget {
  final bool isDark;
  const ExplorarGruposPage({super.key, required this.isDark});

  @override
  State<ExplorarGruposPage> createState() => _ExplorarGruposPageState();
}

class _ExplorarGruposPageState extends State<ExplorarGruposPage> {
  String queryPesquisa = "";
  final user = FirebaseAuth.instance.currentUser;

  Color get bgMain =>
      widget.isDark ? const Color(0xFF1D0000) : const Color(0xFFEAFaf1);
  Color get textMain => widget.isDark ? Colors.white : Colors.black;
  Color get pillBg =>
      widget.isDark ? const Color(0xFF333333) : const Color(0xFFB0B0B0);

  // Função auxiliar para gerenciar a imagem (Cloudinary ou Assets)
  ImageProvider? _obterImagem(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http')) return CachedNetworkImageProvider(url);
    return AssetImage(url);
  }

  Future<void> _entrarNoGrupo(String grupoId) async {
    if (user == null) return;

    try {
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

      await FirebaseFirestore.instance.collection('grupos').doc(grupoId).update(
        {
          'membros_ids': FieldValue.arrayUnion([user!.uid]),
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Você entrou no grupo!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Volta pra Home depois de entrar!
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erro ao entrar no grupo."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // 2 Abas: Grupos e Usuários
      child: Scaffold(
        backgroundColor: bgMain,
        appBar: AppBar(
          backgroundColor: widget.isDark
              ? const Color(0xFF4A0000)
              : Colors.green,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "Explorar",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(icon: Icon(Icons.groups), text: "Grupos"),
              Tab(icon: Icon(Icons.person_search), text: "Usuários"),
            ],
          ),
        ),
        body: Column(
          children: [
            // --- BARRA DE PESQUISA (Fica fixa no topo pras duas abas) ---
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                style: TextStyle(color: textMain),
                onChanged: (valor) => setState(() => queryPesquisa = valor),
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Buscar por nome...",
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: pillBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // --- CONTEÚDO DAS ABAS ---
            Expanded(
              child: TabBarView(
                children: [_buildAbaGrupos(), _buildAbaUsuarios()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // ABA 1: LISTA DE GRUPOS (Lógica original)
  // ==========================================
  Widget _buildAbaGrupos() {
    return StreamBuilder<QuerySnapshot>(
      stream: queryPesquisa.isEmpty
          ? FirebaseFirestore.instance
                .collection('grupos')
                .orderBy('data_criacao', descending: true)
                .limit(20)
                .snapshots()
          : FirebaseFirestore.instance
                .collection('grupos')
                .where('nome', isGreaterThanOrEqualTo: queryPesquisa)
                .where('nome', isLessThan: queryPesquisa + 'z')
                .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              "Nenhum grupo encontrado.",
              style: TextStyle(color: textMain),
            ),
          );
        }

        var grupos = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: grupos.length,
          itemBuilder: (context, index) {
            var dados = grupos[index].data() as Map<String, dynamic>;
            String idDoGrupo = grupos[index].id;
            String nomeDoGrupo = dados['nome'] ?? "Sem nome";
            List membrosIds = dados['membros_ids'] ?? [];
            bool jaParticipa = user != null && membrosIds.contains(user!.uid);

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
                    backgroundColor: Colors.greenAccent[700],
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
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                          "${membrosIds.length} membro(s)",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                            backgroundColor: widget.isDark
                                ? Colors.red[700]
                                : Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => _entrarNoGrupo(idDoGrupo),
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
    );
  }

  // ==========================================
  // ABA 2: LISTA DE USUÁRIOS (Rede Social)
  // ==========================================
  Widget _buildAbaUsuarios() {
    return StreamBuilder<QuerySnapshot>(
      stream: queryPesquisa.isEmpty
          ? FirebaseFirestore.instance
                .collection('usuarios')
                .limit(20)
                .snapshots() // Mostra alguns usuários sugeridos
          : FirebaseFirestore.instance
                .collection('usuarios')
                .where(
                  'nome',
                  isGreaterThanOrEqualTo: queryPesquisa,
                ) // Pesquisa pelo nome
                .where('nome', isLessThan: queryPesquisa + 'z')
                .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              "Nenhum usuário encontrado.",
              style: TextStyle(color: textMain),
            ),
          );
        }

        var usuarios = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: usuarios.length,
          itemBuilder: (context, index) {
            var dados = usuarios[index].data() as Map<String, dynamic>;
            String userId = usuarios[index].id;

            // Não mostra o próprio usuário na lista de pesquisa
            if (userId == user?.uid) return const SizedBox.shrink();

            String nomeUsuario =
                dados['nome_exibicao'] ?? dados['nome'] ?? "Usuário";
            String bio = dados['bio'] ?? "Estudante no Studdy-Buddy";
            String? fotoUrl = dados['url_perfil'];

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
                    backgroundColor: Colors.blueAccent[700],
                    radius: 25,
                    backgroundImage: _obterImagem(fotoUrl),
                    child: (fotoUrl == null || fotoUrl.isEmpty)
                        ? Text(
                            nomeUsuario.isNotEmpty
                                ? nomeUsuario[0].toUpperCase()
                                : "?",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nomeUsuario,
                          style: TextStyle(
                            color: textMain,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          bio,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: widget.isDark
                          ? Colors.white
                          : Colors.black,
                      side: BorderSide(
                        color: widget.isDark ? Colors.white24 : Colors.grey,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      // Aqui futuramente a gente pode colocar para abrir o perfil público do cara!
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Perfil público em desenvolvimento! 🚧",
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      "Ver Perfil",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
