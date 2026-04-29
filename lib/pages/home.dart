import 'package:flutter/material.dart';
import '../controllers/theme_controller.dart';
import 'criacao_grupo.dart';
import 'chats_recentes.dart';
import 'registro_atividade.dart';
import 'grupo_page.dart';
import 'perfil.dart';
import '../controllers/grupo_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  final bool isDark;

  const HomePage({super.key, required this.isDark});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late bool isDark;

  @override
  void initState() {
    super.initState();
    isDark = widget.isDark;
  }

  void toggleTheme() async {
    ThemeController.isDark = !ThemeController.isDark;
    await ThemeController.saveTheme(ThemeController.isDark);
    setState(() {
      isDark = ThemeController.isDark;
    });
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
            Expanded(
              child: Stack(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            const SizedBox(height: 50),

                            // --- ÍCONE DE PERFIL COM NAVEGAÇÃO ---
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const PerfilPage(),
                                  ),
                                );
                              },
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
                                  child: Icon(
                                    Icons.person,
                                    color:
                                        textMain, // Usa a cor definida no seu getter
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),
                            const Divider(
                              color: Colors.white24,
                              indent: 15,
                              endIndent: 15,
                            ),

                            // ... restante da sua lista de grupos (ListView.builder)
                          ],
                        ),
                      ),

                      // Título "Recentes"
                      Text(
                        "Recentes",
                        style: TextStyle(
                          color: textMain,
                          fontSize: 28,
                          fontFamily:
                              'Comic Sans MS', // Substitua pela fonte exata do Figma depois
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 📋 LISTA DE RECENTES
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(
                            left: 30,
                            right: 20,
                            bottom: 80,
                          ),
                          itemCount: 10, // Quantidade mockada
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  // Pílula Cinza
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.only(
                                      left: 40,
                                      top: 8,
                                      bottom: 8,
                                      right: 15,
                                    ),
                                    decoration: BoxDecoration(
                                      color: pillBg,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: const Text(
                                      "Ablublé tanana bla bla\nbla...",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  // Avatar sobreposto (vazando para a esquerda)
                                  Positioned(
                                    left: -15,
                                    top: 2,
                                    child: Stack(
                                      children: [
                                        const CircleAvatar(
                                          radius: 18,
                                          backgroundColor: Colors.green,
                                          child: Text(
                                            "P",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 0,
                                          top: 0,
                                          child: CircleAvatar(
                                            radius: 6,
                                            backgroundColor: Colors.red,
                                            child: Text(
                                              "G1",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 5,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  // ⚙️ ENGRENAGEM E TEMA (Canto Inferior Esquerdo)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: GestureDetector(
                      onTap:
                          toggleTheme, // Usando a engrenagem para trocar o tema por enquanto!
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

            // 🔹 SIDEBAR (DIREITA)
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
                  // Botão de Mais
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CriacaoGrupoPage(isDark: isDark),
                        ),
                      );
                    },
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

                  // Lista de Grupos
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      // Procura todos os grupos no Firestore
                      stream: FirebaseFirestore.instance
                          .collection('grupos')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        var grupos = snapshot.data!.docs;

                        return ListView.builder(
                          itemCount: grupos.length,
                          itemBuilder: (context, index) {
                            var dados =
                                grupos[index].data() as Map<String, dynamic>;
                            String idDoGrupo = grupos[index]
                                .id; // Este é o ID real do documento!
                            String nomeDoGrupo = dados['nome'] ?? "Sem nome";

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GrupoPage(
                                      isDark: isDark,
                                      grupoNome: nomeDoGrupo,
                                      grupoId:
                                          idDoGrupo, // Passamos o ID REAL para a página do grupo
                                    ),
                                  ),
                                );
                              },
                              child: _buildCardGrupo(
                                nomeDoGrupo,
                              ), // Teu widget de estilo do card
                            );
                          },
                        );
                      },
                    ),
                  ),

                  // Ícone de Mensagem no final
                  // Ícone de Mensagem no final da barra lateral
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ChatsRecentesPage(isDark: isDark),
                        ),
                      );
                    },
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
        color: const Color(0xFF5A5A5A), // Cor de fundo para combinar com o tema
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ), // Borda branca como no seu print antigo
      ),
      child: Center(
        child: Text(
          // Pega a primeira letra do nome do grupo para colocar na bolinha
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
