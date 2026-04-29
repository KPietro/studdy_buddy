import 'package:cloud_firestore/cloud_firestore.dart';

class AtividadeController {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> registrarAtividade({
    required String groupId,
    required String userId,
    required String nomeAtividade,
    required int minutos,
  }) async {
    // Lógica oficial: 1 ponto por minuto investido
    int pontosGanhos = minutos;

    // 1. Adiciona a atividade na sub-coleção 'tarefas' do grupo
    await _db.collection('grupos').doc(groupId).collection('tarefas').add({
      'nome': nomeAtividade,
      'minutos': minutos,
      'pontos': pontosGanhos,
      'usuario_id': userId,
      'data': FieldValue.serverTimestamp(),
    });

    // 2. Atualiza o campo 'pontos_total' do usuário
    DocumentReference userRef = _db.collection('usuarios').doc(userId);

    await _db.runTransaction((transaction) async {
      DocumentSnapshot userSnap = await transaction.get(userRef);
      if (userSnap.exists) {
        int pontosAtuais = userSnap.get('pontos_total') ?? 0;
        transaction.update(userRef, {
          'pontos_total': pontosAtuais + pontosGanhos,
        });
      }
    });
  }
}
