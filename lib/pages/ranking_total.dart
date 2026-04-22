import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RankingTotal extends StatelessWidget {
  const RankingTotal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Mudei para um fundo ainda mais profundo para o Ranking Total
      backgroundColor: const Color(0xFF0F0000),
      appBar: AppBar(
        title: const Text(
          "HALL DA FAMA (TOTAL)",
          style: TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('usuarios')
            .orderBy('pontos_total', descending: true)
            .limit(50)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return const Center(
              child: Text(
                "Erro ao carregar dados",
                style: TextStyle(color: Colors.white),
              ),
            );
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            );
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty)
            return const Center(
              child: Text(
                "Nenhum lendário ainda...",
                style: TextStyle(color: Colors.white),
              ),
            );

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final user = docs[index].data() as Map<String, dynamic>;
              final rank = index + 1;

              // Mudança visual: Os 3 primeiros ganham um card especial "Dourado"
              bool isTop3 = rank <= 3;

              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isTop3
                      ? const Color(0xFF3D0808)
                      : const Color(0xFF1A0505),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isTop3
                        ? Colors.amber.withOpacity(0.5)
                        : Colors.white10,
                    width: isTop3 ? 2 : 1,
                  ),
                  boxShadow: isTop3
                      ? [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  children: [
                    // Rank com ícone de coroa para o #1
                    SizedBox(
                      width: 40,
                      child: rank == 1
                          ? const Icon(
                              Icons.emoji_events,
                              color: Colors.amber,
                              size: 28,
                            )
                          : Text(
                              "#$rank",
                              style: TextStyle(
                                color: isTop3 ? Colors.amber : Colors.white70,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                    ),
                    const SizedBox(width: 10),
                    // Foto com borda colorida
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isTop3 ? Colors.amber : Colors.red,
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey[900],
                        backgroundImage: user['foto_url'] != ""
                            ? NetworkImage(user['foto_url'])
                            : null,
                        child: user['foto_url'] == ""
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 15),
                    // Dados do Usuário
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user['nome_exibicao'] ?? "Estudante",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              shadows: isTop3
                                  ? [
                                      const Shadow(
                                        color: Colors.black,
                                        blurRadius: 2,
                                      ),
                                    ]
                                  : [],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                color: Colors.grey,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${user['tarefas_concluidas'] ?? 0} Missões",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Pontuação Total
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "${user['pontos_total']}",
                          style: TextStyle(
                            color: isTop3 ? Colors.amber : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const Text(
                          "PTS TOTAIS",
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
