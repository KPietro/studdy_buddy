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
                  'Ranking Semanal',
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildPilar(1, 130, isDark),
        const SizedBox(width: 15),
        _buildPilar(1, 180, isDark),
        const SizedBox(width: 15),
        _buildPilar(3, 110, isDark),
      ],
    );
  }

  Widget _buildPilar(int posicao, double altura, bool isDark) {
    const double larguraFrente = 50.0;
    const double depth = 15.0; // Profundidade do 3D
    const double angle = 0.5; // Inclinação
    final double dy = depth * angle; // O espaço que a tampa ocupa para cima

    // Ajuste aqui para as cores reais do seu app
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

        // O CustomPaint faz todo o trabalho de desenhar as 3 faces!
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

  // --- BARRA INFERIOR CURVADA (Estilo CSS) ---
  Widget _buildBottomBar(bool isDark, BuildContext context) {
    return CurvedNavigationBar(
      // A cor do fundo por trás da curva (precisa ser a mesma cor do Scaffold para dar o efeito de transparência)
      backgroundColor: isDark ? bgEscuro : bgClaro,
      // A cor da barra em si
      color: isDark ? baseEscura : baseClara,
      // Cor do botão circular que flutua na curva
      buttonBackgroundColor: isDark ? baseEscura : baseClara,
      // Altura da barra
      height: 60,
      // Tempo da animação da onda
      animationDuration: const Duration(milliseconds: 300),
      // O ícone que começa selecionado (0 = Semanal, 1 = Total)
      index: 0,

      items: const <Widget>[
        Icon(Icons.emoji_events, color: Colors.deepOrange, size: 30),
        Icon(Icons.workspace_premium, color: Colors.yellow, size: 30),
      ],

      onTap: (index) {
        // Se clicar no ícone 1 (Ranking Total), ele navega
        if (index == 1) {
          // Pequeno delay para dar tempo de ver a animação da curva antes de trocar de tela
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
    const double W = 50.0; // Largura da frente
    const double D = 15.0; // Profundidade
    const double angle = 0.5;
    final double Dy = D * angle;

    // Configurando as tintas para preenchimento
    final paintFront = Paint()
      ..color = colorFront
      ..style = PaintingStyle.fill;
    final paintSide = Paint()
      ..color = colorSide
      ..style = PaintingStyle.fill;
    final paintTop = Paint()
      ..color = colorTop
      ..style = PaintingStyle.fill;

    // Configurando a tinta para as bordas pretas
    final paintBorder = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // O "chão" da nossa pintura fica no limite inferior do widget
    final base = altura + Dy;

    // 1. Desenhando a Face Frontal
    final pathFront = Path()
      ..moveTo(0, base) // Quina inferior esquerda
      ..lineTo(W, base) // Quina inferior direita
      ..lineTo(W, Dy) // Quina superior direita
      ..lineTo(0, Dy) // Quina superior esquerda
      ..close();

    // 2. Desenhando a Face Lateral (Direita)
    final pathSide = Path()
      ..moveTo(W, base) // Conecta com a quina inferior direita da frente
      ..lineTo(W + D, base - Dy) // Vai pro fundo e sobe
      ..lineTo(W + D, 0) // Sobe até o topo do fundo
      ..lineTo(W, Dy) // Conecta com a quina superior direita da frente
      ..close();

    // 3. Desenhando a Face Superior (Tampa)
    final pathTop = Path()
      ..moveTo(0, Dy) // Conecta com a quina superior esquerda da frente
      ..lineTo(W, Dy) // Conecta com a quina superior direita da frente
      ..lineTo(W + D, 0) // Vai pro fundo à direita
      ..lineTo(D, 0) // Vai pro fundo à esquerda
      ..close();

    // Pinta as cores das faces
    canvas.drawPath(pathFront, paintFront);
    canvas.drawPath(pathSide, paintSide);
    canvas.drawPath(pathTop, paintTop);

    // Pinta as linhas de contorno (bordas) por cima de tudo
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
