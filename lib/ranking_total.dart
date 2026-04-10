import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart'; // Importação do pacote da curva
import 'ranking_semanal.dart'; // Importe o outro arquivo aqui

class RankingTotal extends StatefulWidget {
  const RankingTotal({super.key});

  @override
  State<RankingTotal> createState() => _RankingTotalState();
}

class _RankingTotalState extends State<RankingTotal> {
  bool isTemaEscuro = true;

  // Paleta de Cores
  final Color bgEscuro = const Color(0xFF2B0505);
  final Color baseEscura = const Color(0xFF4A0000);
  final Color bgClaro = const Color(0xFFEAFaf1);
  final Color baseClara = const Color(0xFF4CAF50);
  final Color verdemeiescuro = const Color.fromRGBO(25, 170, 45, 1);
  final Color verdeNeon = const Color.fromARGB(255, 55, 255, 20);

  // Dados do Total (Pontuações maiores)
  final List<Map<String, dynamic>> jogadores = List.generate(15, (index) {
    String nome;
    int pontos;

    if (index == 0) {
      nome = "Brayan Henrique";
      pontos = 90000;
    } else if (index == 1) {
      nome = "Pietro Lagos";
      pontos = 80000;
    } else if (index == 2) {
      nome = "Tim";
      pontos = 40000;
    } else if (index == 3) {
      nome = "Pietro henry";
      pontos = 9000;
    } else {
      nome = "Brayan Henrique";
      pontos = 30000;
    }

    return {"posicao": index + 1, "nome": nome, "pontos": pontos};
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = isTemaEscuro;

    return Scaffold(
      backgroundColor: isDark ? bgEscuro : bgClaro,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark),
            const SizedBox(height: 20),
            _buildPodio(isDark),
            const SizedBox(height: 30),
            Expanded(child: _buildLista(isDark)),
          ],
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

  // --- CABEÇALHO ---
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

  // --- PÓDIO 3D ---
  Widget _buildPodio(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildPilar(2, 142, isDark),
        const SizedBox(width: 15),
        _buildPilar(1, 160, isDark),
        const SizedBox(width: 15),
        _buildPilar(3, 124, isDark),
      ],
    );
  }

  Widget _buildPilar(int posicao, double altura, bool isDark) {
    const double larguraFrente = 50.0;
    const double depth = 15.0;
    const double angle = 0.5;
    final double dy = depth * angle;

    final colorFront = isDark ? Colors.greenAccent : Colors.greenAccent[400]!;
    final colorSide = isDark ? Colors.green[800]! : Colors.green[700]!;
    final colorTop = isDark ? Colors.green[900]! : Colors.green[800]!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: isDark ? Colors.grey[800] : Colors.grey[400],
          child: const Icon(Icons.person, color: Colors.white),
        ),
        const SizedBox(height: 10),

        CustomPaint(
          size: Size(larguraFrente + depth, altura + dy),
          painter: PillarPainter(
            altura: altura,
            colorFront: colorFront,
            colorSide: colorSide,
            colorTop: colorTop,
          ),
        ),
      ],
    );
  }

  // --- LISTA DE JOGADORES ---
  Widget _buildLista(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      itemCount: jogadores.length,
      itemBuilder: (context, index) {
        final j = jogadores[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 7),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark ? Colors.black : Colors.white,
            border: Border.all(),
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
              const CircleAvatar(
                radius: 12,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 15),
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
                  horizontal: 23,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: verdemeiescuro,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  'PTS   ${j["pontos"]}',
                  style: const TextStyle(
                    color: Color.fromARGB(249, 255, 255, 255),
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

  // --- BARRA INFERIOR CURVADA ---
  Widget _buildBottomBar(bool isDark, BuildContext context) {
    return CurvedNavigationBar(
      // A cor do fundo tem que ser a mesma do Scaffold
      backgroundColor: isDark ? bgEscuro : bgClaro,
      // A cor da barra e do botão flutuante
      color: isDark ? baseEscura : baseClara,
      buttonBackgroundColor: isDark ? baseEscura : baseClara,
      height: 60,
      animationDuration: const Duration(milliseconds: 300),

      // AQUI ESTÁ O SEGREDO DO TOTAL: O index inicial é 1 (o segundo botão)
      index: 1,

      items: const <Widget>[
        Icon(Icons.emoji_events, color: Colors.deepOrange, size: 30),
        Icon(Icons.workspace_premium, color: Colors.yellow, size: 30),
      ],

      onTap: (index) {
        // Se clicar no troféu laranja (index 0), volta para o Semanal
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

// ==========================================
// CLASSE DO PILAR 3D
// ==========================================
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
