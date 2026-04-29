import 'package:flutter/material.dart';
import '../controllers/grupo_controller.dart';

class CriacaoGrupoPage extends StatefulWidget {
  final bool isDark;

  const CriacaoGrupoPage({super.key, required this.isDark});

  @override
  State<CriacaoGrupoPage> createState() => _CriacaoGrupoPageState();
}

class _CriacaoGrupoPageState extends State<CriacaoGrupoPage> {
  final _nomeController = TextEditingController();
  final _pontosMinutoController = TextEditingController(
    text: "1",
  ); // Padrão 1 por minuto
  final _pontosMetaController = TextEditingController();
  final _nomeTopController = TextEditingController();

  bool _isLoading = false;

  Color get bgMain =>
      widget.isDark ? const Color(0xFF1C0113) : const Color(0xFFEAFaf1);
  Color get textMain => widget.isDark ? Colors.white : Colors.black;

  Future<void> _salvarGrupo() async {
    final nome = _nomeController.text.trim();
    final pontosMinuto = int.tryParse(_pontosMinutoController.text) ?? 1;
    final pontosMeta = int.tryParse(_pontosMetaController.text) ?? 0;
    final nomeTop = _nomeTopController.text.trim();

    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O nome do grupo é obrigatório!')),
      );
      return;
    }
    //
    setState(() => _isLoading = true);

    await GrupoController.criarGrupo(
      nome: nome,
      pontosPorMinuto: pontosMinuto,
      pontosMetaMaior: pontosMeta,
      nomeTopSemana: nomeTop,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Grupo criado com sucesso!')),
      );
      Navigator.pop(context); // Volta para a tela Home
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgMain, // Fundo escuro do briefing
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textMain),
        title: Text('Criar Grupo', style: TextStyle(color: textMain)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(_nomeController, 'Nome do Grupo'),
            const SizedBox(height: 15),
            _buildTextField(
              _pontosMinutoController,
              'Pontos por minuto (Padrão: 1)',
              isNumber: true,
            ),
            const SizedBox(height: 15),
            _buildTextField(
              _pontosMetaController,
              'Pontos para Meta Maior (Ex: Simulado)',
              isNumber: true,
            ),
            const SizedBox(height: 15),
            _buildTextField(_nomeTopController, 'Nome para o Top da Semana'),
            const SizedBox(height: 30),

            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFC21A01)),
                  )
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFFC21A01,
                      ), // Laranja primário
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _salvarGrupo,
                    child: const Text(
                      'Criar Grupo',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: TextStyle(color: textMain),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF6B0103)), // Vermelho primário
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFC21A01)),
        ),
      ),
    );
  }
}
