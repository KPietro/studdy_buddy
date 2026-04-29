import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GrupoController {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Pega o ID do usuário que está logado no app
  static String get currentUserId => _auth.currentUser?.uid ?? "";

  // Função para salvar o grupo no Firebase
  static Future<void> criarGrupo({
    required String nome,
    required int pontosPorMinuto,
    required int pontosMetaMaior,
    required String nomeTopSemana,
  }) async {
    if (currentUserId.isEmpty) return;

    // Cria um novo documento na coleção 'grupos'
    await _db.collection('grupos').add({
      'nome': nome,
      'pontos_por_minuto': pontosPorMinuto,
      'pontos_meta_maior': pontosMetaMaior,
      'nome_top_semana': nomeTopSemana,
      'lider_id': currentUserId, // Define você como criador/líder
      'membros': [currentUserId], // Já te coloca como o primeiro membro
      'data_criacao': FieldValue.serverTimestamp(),
      'cor_tema': '#6B0103', // Cor padrão do briefing
    });
  }
}
