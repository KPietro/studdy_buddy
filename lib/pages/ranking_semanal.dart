import 'package:flutter/material.dart';
import 'ranking_total.dart'; // Importe o outro arquivo aqui
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class RankingSemanal extends StatefulWidget {
  const RankingSemanal({super.key});

  @override
  State<RankingSemanal> createState() => _RankingSemanalState();
}

class _RankingSemanalState extends State<RankingSemanal> {
  bool isTemaEscuro = true; // Controle do tema nesta tela

  // Paleta de Cores
  final Color bgEscuro = const Color(0xFF2B0505);
  final Color baseEscura = const Color(0xFF4A0000);
  final Color bgClaro = const Color(0xFFEAFaf1);
  final Color baseClara = const Color(0xFF4CAF50);
  final Color verdemeiescuro = const Color.fromRGBO(25, 170, 45, 1);
  final Color verdeEscuro = const Color(0xFF00AA00);
  final Color verdeNeon = const Color.fromARGB(255, 55, 255, 20);

  // Dados do Semanal
  final List<Map<String, dynamic>> jogadores = List.generate(
    15,
    (index) => {
      "posicao": index + 1,
      "nome": index == 1
          ? "Pietro Lagos"
          : (index == 2 ? "Tim" : "Brayan Henrique"),
      "pontos": 30000 - (index * 1000),
    },
  );

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
                  '  Ranking Semanal',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(
                  Icons.emoji_events,
                  color: Colors.deepOrange,
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

  Widget _buildPodio(bool isDark) {
    // Envolvi o pódio em um SizedBox com altura fixa (250) para garantir que
    // a animação cresça de baixo para cima sem empurrar a lista para baixo.
    return SizedBox(
      height: 250,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildPilar(2, 130, isDark),
          const SizedBox(width: 15),
          _buildPilar(1, 180, isDark),
          const SizedBox(width: 15),
          _buildPilar(3, 110, isDark),
        ],
      ),
    );
  }

  Widget _buildPilar(int posicao, double alturaAlvo, bool isDark) {
    const double larguraFrente = 50.0;
    const double depth = 15.0; // Profundidade do 3D
    const double angle = 0.5; // Inclinação
    final double dy = depth * angle; // O espaço que a tampa ocupa para cima

    // Cores EXATAS e fixas, sem mudar com o tema claro/escuro
    final Color colorFront = Colors.greenAccent;
    final Color colorSide = Colors.green[800]!;
    final Color colorTop = Colors.green[900]!;

    // O TweenAnimationBuilder é a mágica que faz o gráfico sair do zero e subir!
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: 0.0,
        end: alturaAlvo,
      ), // Vai do 0 até a altura alvo
      duration: const Duration(milliseconds: 1500), // 1.5 segundos de animação
      curve:
          Curves.easeOutCubic, // Curva suave (começa rápido e freia no final)
      builder: (context, alturaAnimada, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[400],
              child: const Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(height: 10),

            // O CustomPaint agora usa a "alturaAnimada" que está crescendo a cada frame
            CustomPaint(
              size: Size(larguraFrente + depth, alturaAnimada + dy),
              painter: PillarPainter(
                altura: alturaAnimada, // Passa o valor animado para o pintor
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
              Container(
                margin: const EdgeInsets.only(left: 5),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(199, 0, 0, 1),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  'QTT:10',
                  style: const TextStyle(
                    color: Color.fromRGBO(2555, 255, 255, 1),
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
      backgroundColor: isDark ? bgEscuro : bgClaro,
      color: isDark ? baseEscura : baseClara,
      buttonBackgroundColor: isDark ? baseEscura : baseClara,
      height: 60,
      animationDuration: const Duration(milliseconds: 300),
      index: 0,
      items: const <Widget>[
        Icon(Icons.emoji_events, color: Colors.deepOrange, size: 30),
        Icon(Icons.workspace_premium, color: Colors.yellow, size: 30),
      ],
      onTap: (index) {
        if (index == 1) {
          Future.delayed(const Duration(milliseconds: 300), () {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) =>
                    const RankingTotal(),
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
    // Se a altura for muito pequena, não desenha para evitar bugs visuais
    if (altura <= 0.1) return;

    const double W = 50.0; // Largura da frente
    const double D = 15.0; // Profundidade
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
    // Só redesenha se a altura mudar (Performance 100%)
    return oldDelegate.altura != altura;
  }
}
