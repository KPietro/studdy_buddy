import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/settings_controller.dart';

import 'criacao_grupo.dart';
import 'chats_recentes.dart';
import 'registro_atividade.dart';
import 'grupo_page.dart';
import 'perfil.dart';
import 'config_page.dart';
import '../controllers/grupo_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Color _bgMain(bool isDark) =>
      isDark ? const Color(0xFF160303) : const Color(0xFFEAFaf1);

  Color _bgSidebar(bool isDark) =>
      isDark ? const Color(0xFF4A0000) : const Color(0xFF4CAF50);

  Color _textMain(bool isDark) =>
      isDark ? Colors.white : Colors.black;

  Color _pillBg(bool isDark) =>
      isDark ? const Color(0xFF333333) : const Color(0xFFB0B0B0);

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsController>(context);
    final isDark = settings.isDarkMode;

    return Scaffold(
      backgroundColor: _bgMain(isDark),

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

                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const PerfilPage(),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white24
                                        : Colors.black26,
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
                                    color: _textMain(isDark),
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Text(
                        "Recentes",
                        style: TextStyle(
                          color: _textMain(isDark),
                          fontSize: 28,
                          fontFamily: 'Comic Sans MS',
                        ),
                      ),

                      const SizedBox(height: 20),

                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(
                            left: 30,
                            right: 20,
                            bottom: 80,
                          ),
                          itemCount: 10,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.only(
                                      left: 40,
                                      top: 8,
                                      bottom: 8,
                                      right: 15,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _pillBg(isDark),
                                      borderRadius:
                                          BorderRadius.circular(25),
                                    ),
                                    child: Text(
                                      "Ablublé tanana bla bla\nbla...",
                                      style: TextStyle(
                                        color: _textMain(isDark),
                                        fontSize: 12,
                                      ),
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

                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ConfigPage(),
                          ),
                        );
                      },
                      child: Icon(
                        Icons.settings,
                        color:
                            isDark ? Colors.red : Colors.greenAccent,
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
                color: _bgSidebar(isDark),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
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
                            var dados = grupos[index].data()
                                as Map<String, dynamic>;

                            String idDoGrupo = grupos[index].id;
                            String nomeDoGrupo =
                                dados['nome'] ?? "Sem nome";

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
      decoration: const BoxDecoration(
        color: Color(0xFF5A5A5A),
        shape: BoxShape.circle,
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