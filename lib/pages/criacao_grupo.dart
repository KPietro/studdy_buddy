import 'package:flutter/material.dart';

class CriacaoGrupoPage extends StatefulWidget {
  final bool isDark;
  const CriacaoGrupoPage({super.key, required this.isDark});

  @override
  State<CriacaoGrupoPage> createState() => _CriacaoGrupoPageState();
}

class _CriacaoGrupoPageState extends State<CriacaoGrupoPage> {
  Color get bgMain => widget.isDark ? const Color(0xFF1D0000) : const Color(0xFFEAFaf1);
  Color get textMain => widget.isDark ? Colors.white : Colors.black;
  Color get pillBg => widget.isDark ? const Color(0xFF333333) : Colors.white;

  final nomeController = TextEditingController();
  final pontosMinutoController = TextEditingController(text: "1"); // Padrão 1
  final metaMaiorController = TextEditingController();
  final tituloSemanalController = TextEditingController();
  final tituloTotalController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgMain,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textMain),
        title: Text("Criar Novo Grupo", style: TextStyle(color: textMain, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Nome do Grupo"),
            _buildTextField(nomeController, "Ex: Os Aprovados"),
            
            _buildLabel("Pontos por minuto investido (Padrão: 1)"),
            _buildTextField(pontosMinutoController, "1", isNumber: true),

            _buildLabel("Pontos de uma Meta Maior (Ex: Simulado)"),
            _buildTextField(metaMaiorController, "Ex: 500", isNumber: true),

            const SizedBox(height: 20),
            Divider(color: widget.isDark ? Colors.red.withOpacity(0.5) : Colors.green),
            const SizedBox(height: 10),

            const Text(
              "🏅 Configurações de Títulos (Medalhas)",
              style: TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Estes nomes aparecerão no ranking. O criador ou líder pode alterar depois. O nome do top semanal será definido por quem ver a notificação primeiro todo domingo!",
              style: TextStyle(color: textMain.withOpacity(0.7), fontSize: 12),
            ),
            const SizedBox(height: 20),

            _buildLabel("Título do Top 1 Semanal"),
            _buildTextField(tituloSemanalController, "Ex: O Sabichão da Semana"),

            _buildLabel("Título do Top 1 Total"),
            _buildTextField(tituloTotalController, "Ex: O Grande Mestre"),

            const SizedBox(height: 40),
            
            // Botão Criar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.isDark ? Colors.red[700] : Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Grupo criado com sucesso! (Visual)")),
                  );
                  Navigator.pop(context);
                },
                child: const Text("Criar Grupo", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 15),
      child: Text(text, style: TextStyle(color: textMain, fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false}) {
    return Container(
      decoration: BoxDecoration(
        color: pillBg,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: widget.isDark ? Colors.white24 : Colors.grey),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
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
}