import 'package:flutter/material.dart';

class RegistroAtividadePage extends StatefulWidget {
  final bool isDark;
  const RegistroAtividadePage({super.key, required this.isDark});

  @override
  State<RegistroAtividadePage> createState() => _RegistroAtividadePageState();
}

class _RegistroAtividadePageState extends State<RegistroAtividadePage> {
  Color get bgMain => widget.isDark ? const Color(0xFF1D0000) : const Color(0xFFEAFaf1);
  Color get textMain => widget.isDark ? Colors.white : Colors.black;
  Color get pillBg => widget.isDark ? const Color(0xFF333333) : Colors.white;

  bool usarTimer = true;
  bool timerRodando = false;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Número de "Sub Abas"
      child: Scaffold(
        backgroundColor: bgMain,
        appBar: AppBar(
          backgroundColor: widget.isDark ? const Color(0xFF4A0000) : Colors.green,
          title: const Text("Registrar Atividade", style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(text: "Atividade Comum", icon: Icon(Icons.timer)),
              Tab(text: "Tarefa Maior", icon: Icon(Icons.workspace_premium)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAbaComum(),
            _buildAbaMaior(),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // SUB ABA 1: ATIVIDADE COMUM
  // ==========================================
  Widget _buildAbaComum() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel("O que você está fazendo?"),
          _buildTextField("Ex: Lendo capítulo 4 de História"),
          const SizedBox(height: 20),

          // Toggle Timer vs Manual
          Container(
            decoration: BoxDecoration(color: pillBg, borderRadius: BorderRadius.circular(15)),
            child: SwitchListTile(
              title: Text("Usar Cronômetro (Timer)", style: TextStyle(color: textMain, fontWeight: FontWeight.bold)),
              subtitle: Text("Desative para inserir o tempo manualmente", style: TextStyle(color: textMain.withOpacity(0.6), fontSize: 12)),
              activeColor: widget.isDark ? Colors.red : Colors.green,
              value: usarTimer,
              onChanged: (val) => setState(() => usarTimer = val),
            ),
          ),
          const SizedBox(height: 20),

          // Lógica condicional: Mostra o Timer OU o campo de digitar o tempo
          if (usarTimer)
            Center(
              child: Column(
                children: [
                  Text("00:00:00", style: TextStyle(color: textMain, fontSize: 48, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => timerRodando = !timerRodando),
                    icon: Icon(timerRodando ? Icons.stop : Icons.play_arrow, color: Colors.white),
                    label: Text(timerRodando ? "Parar Timer" : "Iniciar Timer", style: const TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: timerRodando ? Colors.red : (widget.isDark ? Colors.red[900] : Colors.green),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel("Tempo investido (em minutos)"),
                _buildTextField("Ex: 45", isNumber: true),
              ],
            ),

          const SizedBox(height: 30),
          _buildBotaoUpload("Adicionar Foto / Print (Opcional)", Icons.add_a_photo),
          const SizedBox(height: 10),
          _buildTextField("Descrição opcional...", maxLines: 3),
          const SizedBox(height: 30),
          _buildBotaoEnviar(),
        ],
      ),
    );
  }

  // ==========================================
  // SUB ABA 2: TAREFA MAIOR (Ex: Simulado)
  // ==========================================
  Widget _buildAbaMaior() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.amber)),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.amber),
                const SizedBox(width: 10),
                Expanded(child: Text("Tarefas maiores exigem comprovação! Foto e descrição detalhada são obrigatórios.", style: TextStyle(color: textMain, fontSize: 12))),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _buildLabel("Qual foi a Tarefa Maior?"),
          _buildTextField("Ex: Simulado ENEM do cursinho"),
          
          _buildLabel("Tempo investido (em minutos)"),
          _buildTextField("Ex: 240", isNumber: true),

          const SizedBox(height: 20),
          _buildBotaoUpload("Adicionar Foto/Print do Resultado (OBRIGATÓRIO)", Icons.camera_alt, obrigatorio: true),
          
          const SizedBox(height: 15),
          _buildLabel("Descrição (OBRIGATÓRIO)"),
          _buildTextField("Explique suas dificuldades e o que achou da tarefa...", maxLines: 4),

          const SizedBox(height: 30),
          _buildBotaoEnviar(),
        ],
      ),
    );
  }

  // --- Widgets Auxiliares ---
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 15),
      child: Text(text, style: TextStyle(color: textMain, fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  Widget _buildTextField(String hint, {bool isNumber = false, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(color: pillBg, borderRadius: BorderRadius.circular(15), border: Border.all(color: widget.isDark ? Colors.white24 : Colors.grey)),
      child: TextField(
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        style: TextStyle(color: textMain),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildBotaoUpload(String texto, IconData icone, {bool obrigatorio = false}) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icone, color: obrigatorio ? Colors.amber : (widget.isDark ? Colors.red : Colors.green)),
      label: Text(texto, style: TextStyle(color: textMain, fontSize: 12)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: obrigatorio ? Colors.amber : Colors.grey),
        padding: const EdgeInsets.all(15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  Widget _buildBotaoEnviar() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.isDark ? Colors.red[700] : Colors.green,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Atividade enviada para aprovação do Grupo!")));
          Navigator.pop(context);
        },
        child: const Text("Enviar Atividade", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}