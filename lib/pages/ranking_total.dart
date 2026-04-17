import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'ranking_semanal.dart';

class RankingTotal extends StatefulWidget {
  const RankingTotal({super.key});

  @override
  State<RankingTotal> createState() => _RankingTotalState();
}

class _RankingTotalState extends State<RankingTotal> {
  bool isTemaEscuro = true;

  final Color bgEscuro = const Color(0xFF2B0505);
  final Color baseEscura = const Color(0xFF4A0000);
  final Color bgClaro = const Color(0xFFEAFaf1);
  final Color baseClara = const Color(0xFF4CAF50);
  final Color verdemeiescuro = const Color.fromRGBO(25, 170, 45, 1);
  final Color verdeNeon = const Color.fromARGB(255, 55, 255, 20);

  @override
  Widget build(BuildContext context) {
    final bool isDark = isTemaEscuro;

    return Scaffold(
      backgroundColor: isDark ? bgEscuro : bgClaro,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('grupos')
              .doc('G1')
              .collection('membros')
              .orderBy('pontosTotais', descending: true) // ORDENA PELO TOTAL
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  'Nenhum jogador encontrado.',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
              );
            }

            final List<Map<String, dynamic>> jogadores = [];
            final docs = snapshot.data!.docs;

            for (int i = 0; i < docs.length; i++) {
              jogadores.add({
                "posicao": i + 1,
                "nome": docs[i]['nome'] ?? "Sem Nome",
                "pontos": docs[i]['pontosTotais'] ?? 0, // PUXA O TOTAL
                "atividades":
                    docs[i]['atividadesMaioresTotais'] ?? 0, // PUXA O TOTAL
                "fotoPerfil": docs[i]['fotoPerfil'],
              });
            }

            return Column(
              children: [
                _buildHeader(isDark),
                const SizedBox(height: 20),
                _buildPodio(isDark, jogadores),
                const SizedBox(height: 30),
                Expanded(child: _buildLista(isDark, jogadores)),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: _buildBottomBar(isDark, context),
      floatingActionButton: FloatingActionButton(
        backgroundColor: verdeNeon,
        mini: true,
        onPressed: () => setState(() => isTemaEscuro = !isTemaEscuro),
        child: Icon(
          isDark ? Icons.light_mode : Icons.dark_mode,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFB30000),
            radius: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {},
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Ranking Total',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(
                  Icons.workspace_premium,
                  color: Colors.yellow,
                  size: 30,
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildPodio(bool isDark, List<Map<String, dynamic>> jogadores) {
    return SizedBox(
      height: 250,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (jogadores.length > 1) _buildPilar(jogadores[1], 142, isDark),
          const SizedBox(width: 15),
          if (jogadores.isNotEmpty) _buildPilar(jogadores[0], 160, isDark),
          const SizedBox(width: 15),
          if (jogadores.length > 2) _buildPilar(jogadores[2], 124, isDark),
        ],
      ),
    );
  }

  Widget _buildPilar(Map<String, dynamic> j, double altura, bool isDark) {
    const double larguraFrente = 50.0;
    const double depth = 15.0;
    const double angle = 0.5;
    final double dy = depth * angle;
    int alturaquero = altura.toInt(); // Sua lógica mantida

    final colorFront = isDark ? Colors.greenAccent : Colors.greenAccent[400]!;
    final colorSide = isDark ? Colors.green[800]! : Colors.green[700]!;
    final colorTop = isDark ? Colors.green[900]! : Colors.green[800]!;

    bool temFoto =
        j["fotoPerfil"] != null && j["fotoPerfil"].toString().isNotEmpty;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: altura),
      duration: Duration(milliseconds: 10 * alturaquero), // Sua lógica mantida
      curve: Curves.easeOutCubic,
      builder: (context, alturaAnimada, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[400],
              backgroundImage: temFoto ? NetworkImage(j["fotoPerfil"]) : null,
              child: !temFoto
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 10),
            CustomPaint(
              size: Size(larguraFrente + depth, alturaAnimada + dy),
              painter: PillarPainter(
                altura: alturaAnimada,
                colorFront: colorFront,
                colorSide: colorSide,
                colorTop: colorTop,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLista(bool isDark, List<Map<String, dynamic>> jogadores) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      itemCount: jogadores.length,
      itemBuilder: (context, index) {
        final j = jogadores[index];
        bool temFoto =
            j["fotoPerfil"] != null && j["fotoPerfil"].toString().isNotEmpty;

        return Container(
          margin: const EdgeInsets.only(bottom: 7),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark ? Colors.black : Colors.white,
            border: Border.all(color: Colors.white24),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 30,
                child: j["posicao"] <= 3
                    ? Icon(
                        Icons.military_tech,
                        color: j["posicao"] == 1
                            ? Colors.yellow
                            : (j["posicao"] == 2 ? Colors.grey : Colors.brown),
                      )
                    : Text(
                        '#${j["posicao"]}',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.grey,
                backgroundImage: temFoto ? NetworkImage(j["fotoPerfil"]) : null,
                child: !temFoto
                    ? const Icon(Icons.person, size: 15, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  j["nome"],
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: verdemeiescuro,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  'PTS   ${j["pontos"]}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 5),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(199, 0, 0, 1),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  'QTT:${j["atividades"]}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(bool isDark, BuildContext context) {
    return CurvedNavigationBar(
      backgroundColor: isDark ? bgEscuro : bgClaro,
      color: isDark ? baseEscura : baseClara,
      buttonBackgroundColor: isDark ? baseEscura : baseClara,
      height: 60,
      animationDuration: const Duration(milliseconds: 300),
      index: 1,
      items: const <Widget>[
        Icon(Icons.emoji_events, color: Colors.deepOrange, size: 30),
        Icon(Icons.workspace_premium, color: Colors.yellow, size: 30),
      ],
      onTap: (index) {
        if (index == 0) {
          Future.delayed(const Duration(milliseconds: 300), () {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) =>
                    const RankingSemanal(),
                transitionDuration: Duration.zero,
              ),
            );
          });
        }
      },
    );
  }
}

class PillarPainter extends CustomPainter {
  final double altura;
  final Color colorFront;
  final Color colorSide;
  final Color colorTop;

  PillarPainter({
    required this.altura,
    required this.colorFront,
    required this.colorSide,
    required this.colorTop,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (altura <= 0.1) return;

    const double W = 50.0;
    const double D = 15.0;
    const double angle = 0.5;
    final double Dy = D * angle;

    final paintFront = Paint()
      ..color = colorFront
      ..style = PaintingStyle.fill;
    final paintSide = Paint()
      ..color = colorSide
      ..style = PaintingStyle.fill;
    final paintTop = Paint()
      ..color = colorTop
      ..style = PaintingStyle.fill;

    final paintBorder = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final base = altura + Dy;

    final pathFront = Path()
      ..moveTo(0, base)
      ..lineTo(W, base)
      ..lineTo(W, Dy)
      ..lineTo(0, Dy)
      ..close();
    final pathSide = Path()
      ..moveTo(W, base)
      ..lineTo(W + D, base - Dy)
      ..lineTo(W + D, 0)
      ..lineTo(W, Dy)
      ..close();
    final pathTop = Path()
      ..moveTo(0, Dy)
      ..lineTo(W, Dy)
      ..lineTo(W + D, 0)
      ..lineTo(D, 0)
      ..close();

    canvas.drawPath(pathFront, paintFront);
    canvas.drawPath(pathSide, paintSide);
    canvas.drawPath(pathTop, paintTop);

    canvas.drawPath(pathFront, paintBorder);
    canvas.drawPath(pathSide, paintBorder);
    canvas.drawPath(pathTop, paintBorder);
  }

  @override
  bool shouldRepaint(covariant PillarPainter oldDelegate) {
    return oldDelegate.altura != altura;
  }
}
