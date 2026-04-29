import 'package:flutter/material.dart';
import '../controllers/atividade_controller.dart';

class RegistroAtividadeDialog {
  static void mostrar(
    BuildContext context, {
    required String groupId,
    required String userId,
  }) {
    final nomeController = TextEditingController();
    final tempoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C0113), // Preto
        title: const Text(
          'Registrar Atividade',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomeController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'O que estás a estudar?',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF6B0103)), // Vermelho
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: tempoController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Tempo (em minutos)',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF6B0103)), // Vermelho
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC21A01), // Laranja
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              final nome = nomeController.text;
              final tempo = int.tryParse(tempoController.text) ?? 0;

              if (nome.isNotEmpty && tempo > 0) {
                await AtividadeController.registrarAtividade(
                  groupId: groupId,
                  userId: userId,
                  nomeAtividade: nome,
                  minutos: tempo,
                );
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Salvar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
