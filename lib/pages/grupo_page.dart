import 'package:flutter/material.dart';
import 'ranking_semanal.dart';
import 'registro_atividade.dart';
import 'chat_page.dart';

class GrupoPage extends StatelessWidget {
  final bool isDark;
  final String grupoNome;

  const GrupoPage({super.key, required this.isDark, required this.grupoNome});

  Color get bgMain => isDark ? const Color(0xFF1D0000) : const Color(0xFFEAFaf1);
  Color get textMain => isDark ? Colors.white : Colors.black;
  Color get pillBg => isDark ? const Color(0xFF333333) : const Color(0xFF5A5A5A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgMain,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.greenAccent[700],
                    radius: 22,
                    child: const Text(
                      "P",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
                    ),
                  ), 
                  const SizedBox(width: 15),
                  Expanded(
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5A5A5A),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const TextField(
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                          suffixIcon: Icon(Icons.search, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildTarefaItem(context, "Estudo de 2hrs", "120pts", Colors.greenAccent[700]!, "P", hasProgress: true),
                  _buildTarefaItem(context, "Atividade de redação 25min", "25pts", Colors.blueAccent, Icons.person),
                  _buildTarefaItem(context, "Simulado do Enem 6hrs", "200exp+360pts", Colors.grey, Icons.person),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      child: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
                    ),
                  ),

                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => RegistroAtividadePage(isDark: isDark)),
                          );
                        },
                        child: const Icon(Icons.add_circle_outline, color: Colors.white, size: 45),
                      ),
                      const SizedBox(width: 15),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ChatPage(isDark: isDark, grupoNome: grupoNome)),
                          );
                        },
                        child: const Icon(Icons.email_outlined, color: Colors.white, size: 45),
                      ),
                      const SizedBox(width: 15),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RankingSemanal()),
                          );
                        },
                        child: const Icon(Icons.leaderboard_outlined, color: Colors.red, size: 40),
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

  Widget _buildTarefaItem(BuildContext context, String titulo, String pontos, Color avatarColor, dynamic avatarContent, {bool hasProgress = false}) {
    return GestureDetector(
      onTap: () => _mostrarDetalhesTarefa(context, titulo, pontos),
      child: Container(
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
                    ? Text(avatarContent, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                    : Icon(avatarContent, color: Colors.white),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFF5A5A5A),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Stack(
                  children: [
                    if (hasProgress)
                      Positioned(
                        left: 15,
                        right: 40,
                        bottom: 8,
                        child: Container(height: 3, color: Colors.blue),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(titulo, style: const TextStyle(color: Colors.white, fontSize: 13)),
                          Text(pontos, style: const TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDetalhesTarefa(BuildContext context, String titulo, String pontos) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF2D0505) : const Color(0xFFEAFaf1),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Detalhes da Atividade", style: TextStyle(color: textMain, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              Text("📌 Atividade: $titulo", style: TextStyle(color: textMain, fontSize: 16)),
              const SizedBox(height: 5),
              Text("🏆 Recompensa: $pontos", style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[800],
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _abrirModalQuestionamento(context);
                  },
                  icon: const Icon(Icons.gavel, color: Colors.white),
                  label: const Text("Questionar Tarefa", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _abrirModalQuestionamento(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1D0000) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 25, left: 25, right: 25,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 30),
                  const SizedBox(width: 10),
                  Text("Questionar Atividade", style: TextStyle(color: textMain, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF333333) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey),
                ),
                child: TextField(
                  maxLines: 3,
                  style: TextStyle(color: textMain),
                  decoration: const InputDecoration(
                    hintText: "Descreva o motivo da suspeita...",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(15),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[700],
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Questionamento enviado aos líderes!")),
                    );
                  },
                  child: const Text("Enviar para Análise", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}