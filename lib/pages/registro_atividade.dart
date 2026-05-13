import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegistroAtividadePage extends StatefulWidget {
  final bool isDark;
  final String grupoId; // Recebe o ID do grupo

  const RegistroAtividadePage({
    super.key,
    required this.isDark,
    required this.grupoId,
  });

  @override
  State<RegistroAtividadePage> createState() => _RegistroAtividadePageState();
}

class _RegistroAtividadePageState extends State<RegistroAtividadePage> {
  Color get bgMain =>
      widget.isDark ? const Color(0xFF1D0000) : const Color(0xFFEAFaf1);
  Color get textMain => widget.isDark ? Colors.white : Colors.black;
  Color get pillBg => widget.isDark ? const Color(0xFF333333) : Colors.white;

  final acaoController = TextEditingController();
  final descricaoController = TextEditingController();
  final minutosController = TextEditingController();

  String tipoTarefaSelecionada = 'Comum';
  bool isLoading = false;

  Future<void> _salvarAtividade() async {
    if (acaoController.text.isEmpty || minutosController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha a ação e os minutos!")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Usuário não logado");

      int minutos = int.tryParse(minutosController.text.trim()) ?? 0;

      // 1. LER AS REGRAS DO GRUPO (quantos pontos vale cada minuto)
      DocumentSnapshot grupoDoc = await FirebaseFirestore.instance
          .collection('grupos')
          .doc(widget.grupoId)
          .get();
      var dadosGrupo = grupoDoc.data() as Map<String, dynamic>?;

      int ptsPorMinuto = dadosGrupo?['pontos_minuto'] ?? 1;
      int metaMaiorBonus = dadosGrupo?['meta_maior'] ?? 0;

      // 2. CÁLCULO DOS PONTOS
      int pontosGanhos = minutos * ptsPorMinuto;
      int incrementoAtividadeMaior = 0;

      // Se for uma Meta Maior, ganha os pontos extras e conta +1 nas estatísticas de Atividade Maior
      if (tipoTarefaSelecionada == 'Meta Maior') {
        pontosGanhos += metaMaiorBonus;
        incrementoAtividadeMaior = 1;
      }

      // 3. SALVAR A TAREFA NA SUBCOLEÇÃO
      await FirebaseFirestore.instance
          .collection('grupos')
          .doc(widget.grupoId)
          .collection('tarefas')
          .add({
            'acao': acaoController.text.trim(),
            'descricao': descricaoController.text.trim(),
            'minutos': minutos,
            'tipotarefa': tipoTarefaSelecionada,
            'criador_id': user.uid,
            'data_criacao': FieldValue.serverTimestamp(),
            'urlimagem': "", // Pode implementar upload de imagem depois
          });

      // 4. ATUALIZAR O MEMBRO (INCREMENTANDO OS PONTOS E A QTD DE TAREFAS)
      await FirebaseFirestore.instance
          .collection('grupos')
          .doc(widget.grupoId)
          .collection('membros')
          .doc(user.uid)
          .update({
            'pontosSemanais': FieldValue.increment(pontosGanhos),
            'pontosTotais': FieldValue.increment(pontosGanhos),
            'atividadesMaioresSemanais': FieldValue.increment(
              incrementoAtividadeMaior,
            ),
            'atividadesMaioresTotais': FieldValue.increment(
              incrementoAtividadeMaior,
            ),
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Atividade registrada! Pontos computados."),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao registrar: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgMain,
      appBar: AppBar(
        backgroundColor: widget.isDark ? const Color(0xFF4A0000) : Colors.green,
        title: const Text(
          "Registrar Atividade",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Ação / Título"),
            _buildTextField(acaoController, "Ex: Lendo onde peca"),

            _buildLabel("Descrição"),
            _buildTextField(descricaoController, "Ex: Li 2 capítulos..."),

            _buildLabel("Minutos Investidos"),
            _buildTextField(minutosController, "Ex: 45", isNumber: true),

            _buildLabel("Tipo de Tarefa"),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: pillBg,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: widget.isDark ? Colors.white24 : Colors.grey,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: tipoTarefaSelecionada,
                  dropdownColor: pillBg,
                  isExpanded: true,
                  style: TextStyle(color: textMain),
                  items: const [
                    DropdownMenuItem(
                      value: 'Comum',
                      child: Text("Comum (Apenas tempo)"),
                    ),
                    DropdownMenuItem(
                      value: 'Meta Maior',
                      child: Text("Meta Maior (+ Bônus de Pontos)"),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null)
                      setState(() => tipoTarefaSelecionada = val);
                  },
                ),
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.isDark
                      ? Colors.red[700]
                      : Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: isLoading ? null : _salvarAtividade,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Salvar Atividade",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8, top: 15),
    child: Text(
      text,
      style: TextStyle(
        color: textMain,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    ),
  );

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    bool isNumber = false,
  }) {
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 15,
          ),
        ),
      ),
    );
  }
}
