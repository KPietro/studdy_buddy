import 'package:flutter/material.dart';
import 'ranking_semanal.dart'; // Importando para o botão do pódio funcionar

class GrupoPage extends StatelessWidget {
  final bool isDark;
  final String grupoNome;

  const GrupoPage({super.key, required this.isDark, required this.grupoNome});

  Color get bgMain =>
      isDark ? const Color(0xFF1D0000) : const Color(0xFFEAFaf1);
  Color get textMain => isDark ? Colors.white : Colors.black;
  Color get pillBg => const Color(0xFF5A5A5A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgMain,
      body: SafeArea(
        child: Column(
          children: [
            // 🔍 TOPO (Avatar + Search)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.greenAccent[700],
                    radius: 22,
                    child: const Text(
                      "P",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: pillBg, // Fundo cinza na pesquisa desta tela
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "",
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 12,
                          ),
                          suffixIcon: const Icon(
                            Icons.search,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 📋 LISTA DE TAREFAS
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildTarefaItem(
                    "Estudo de 2hrs",
                    "120pts",
                    Colors.greenAccent[700]!,
                    "P",
                    hasProgress: true,
                  ),
                  _buildTarefaItem(
                    "Atividade de redação 25min",
                    "25pts",
                    Colors.blueAccent,
                    Icons.person,
                  ),
                  _buildTarefaItem(
                    "Simulado do Enem 6hrs",
                    "200exp+360pts",
                    Colors.grey,
                    Icons.person,
                  ),
                ],
              ),
            ),

            // 🔻 BARRA INFERIOR (Voltar, Mais, Email, Pódio)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 20.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botão Voltar
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
                        size: 30,
                      ),
                    ),
                  ),

                  // Ícones da Direita
                  Row(
                    children: [
                      const Icon(
                        Icons.add_circle_outline,
                        color: Colors.white,
                        size: 45,
                      ),
                      const SizedBox(width: 15),
                      const Icon(
                        Icons.email_outlined,
                        color: Colors.white,
                        size: 45,
                      ),
                      const SizedBox(width: 15),
                      GestureDetector(
                        onTap: () {
                          // Navega para o Ranking Semanal quando clica no pódio!
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RankingSemanal(),
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.leaderboard_outlined,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para criar as pílulas de tarefas
  Widget _buildTarefaItem(
    String titulo,
    String pontos,
    Color avatarColor,
    dynamic avatarContent, {
    bool hasProgress = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 20,
            child: CircleAvatar(
              backgroundColor: avatarColor,
              radius: 18,
              child: avatarContent is String
                  ? Text(
                      avatarContent,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Icon(avatarContent, color: Colors.white),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: pillBg,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Stack(
                children: [
                  // Barra de Progresso Azul (se tiver)
                  if (hasProgress)
                    Positioned(
                      left: 15,
                      right: 40,
                      bottom: 8,
                      child: Container(height: 3, color: Colors.blue),
                    ),
                  // Textos
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          titulo,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          pontos,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
