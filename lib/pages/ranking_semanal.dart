import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RankingSemanal extends StatelessWidget {
  const RankingSemanal({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔗 CONEXÃO REAL COM O FIREBASE
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          .orderBy(
            'pontos_semanal',
            descending: true,
          ) // Ordena por pontos semanais
          .limit(20) // Top 20 para não pesar
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return const Center(child: Text("Erro ao carregar ranking"));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.red),
          );
        }

        final docs = snapshot.data!.docs;

        // Se o banco estiver vazio
        if (docs.isEmpty)
          return const Center(
            child: Text(
              "Nenhum dado encontrado",
              style: TextStyle(color: Colors.white),
            ),
          );

        // Mapeia os dados mantendo a estrutura que tu definiu
        return _buildRankingUI(context, docs);
      },
    );
  }

  Widget _buildRankingUI(
    BuildContext context,
    List<QueryDocumentSnapshot> docs,
  ) {
    // Extraímos os Top 3 para o teu Pódio
    final top1 = docs.length > 0
        ? docs[0].data() as Map<String, dynamic>
        : null;
    final top2 = docs.length > 1
        ? docs[1].data() as Map<String, dynamic>
        : null;
    final top3 = docs.length > 2
        ? docs[2].data() as Map<String, dynamic>
        : null;

    // O restante vai para a lista
    final outros = docs.length > 3 ? docs.sublist(3) : [];

    return Scaffold(
      backgroundColor: const Color(0xFF1D0000), // Mantendo sua cor original
      body: Column(
        children: [
          const SizedBox(height: 50),
          // --- ÁREA DO PÓDIO (DESIGN INALTERADO) ---
          SizedBox(
            height: 250,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (top2 != null) _buildPodiumItem(top2, "2", 120),
                if (top1 != null) _buildPodiumItem(top1, "1", 160),
                if (top3 != null) _buildPodiumItem(top3, "3", 100),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // --- LISTA DOS DEMAIS (DESIGN INALTERADO) ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: outros.length,
              itemBuilder: (context, index) {
                final user = outros[index].data() as Map<String, dynamic>;
                return _buildListItem(user, index + 4);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Teu widget de item do Pódio (Visual intocado)
  Widget _buildPodiumItem(
    Map<String, dynamic> user,
    String rank,
    double height,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: user['foto_url'] != ""
              ? NetworkImage(user['foto_url'])
              : null,
          child: user['foto_url'] == "" ? const Icon(Icons.person) : null,
        ),
        const SizedBox(height: 5),
        Text(
          user['nome_exibicao'] ?? "Usuário",
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        Container(
          width: 70,
          height: height,
          decoration: const BoxDecoration(
            color: Color(0xFF4A0000),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          child: Center(
            child: Text(
              rank,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Teu widget de item da Lista (Visual intocado)
  Widget _buildListItem(Map<String, dynamic> user, int rank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2D0505),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Text(
            "#$rank",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 15),
          CircleAvatar(
            radius: 20,
            backgroundImage: user['foto_url'] != ""
                ? NetworkImage(user['foto_url'])
                : null,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['nome_exibicao'] ?? "---",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${user['tarefas_concluidas'] ?? 0} tarefas feitas",
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ],
            ),
          ),
          Text(
            "${user['pontos_semanal']} pts",
            style: const TextStyle(
              color: Colors.greenAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
