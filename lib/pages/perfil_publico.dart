import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../controllers/settings_controller.dart';

class PerfilPublicoPage extends StatefulWidget {
  final String userId;

  const PerfilPublicoPage({super.key, required this.userId});

  @override
  State<PerfilPublicoPage> createState() => _PerfilPublicoPageState();
}

class _PerfilPublicoPageState extends State<PerfilPublicoPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ImageProvider? _obterProvedorDeImagem(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http')) return CachedNetworkImageProvider(url);
    return AssetImage(url);
  }

  Color _hexToColor(String hexCode) {
    try {
      String formattedHex = hexCode.replaceAll('#', '');
      if (formattedHex.length == 6) formattedHex = 'FF$formattedHex';
      return Color(int.parse('0x$formattedHex'));
    } catch (e) {
      return const Color(0xFF444444);
    }
  }

  Future<List<double>> _processarTarefas() async {
    DateTime agora = DateTime.now();
    DateTime hojeMeiaNoite = DateTime(agora.year, agora.month, agora.day);
    DateTime inicioFiltro = hojeMeiaNoite.subtract(const Duration(days: 29));

    Map<String, double> minutosPorDia = {};
    for (int i = 0; i < 30; i++) {
      String dataFormatada = DateFormat(
        'yyyy-MM-dd',
      ).format(inicioFiltro.add(Duration(days: i)));
      minutosPorDia[dataFormatada] = 0.0;
    }

    try {
      QuerySnapshot tarefasQuery = await _firestore
          .collectionGroup('tarefas')
          .where('criador_id', isEqualTo: widget.userId)
          .get();

      for (var doc in tarefasQuery.docs) {
        var data = doc.data() as Map<String, dynamic>;
        Timestamp? ts = data['data_criacao'] as Timestamp?;

        if (ts != null) {
          DateTime dataCriacao = ts.toDate();
          if (dataCriacao.isAfter(inicioFiltro) ||
              dataCriacao.isAtSameMomentAs(inicioFiltro)) {
            String diaFormatado = DateFormat('yyyy-MM-dd').format(dataCriacao);
            if (minutosPorDia.containsKey(diaFormatado)) {
              double valorMinutos =
                  double.tryParse(data['minutos'].toString()) ?? 0.0;
              minutosPorDia[diaFormatado] =
                  (minutosPorDia[diaFormatado] ?? 0.0) + valorMinutos;
            }
          }
        }
      }
    } catch (e) {
      debugPrint("❌ [GRAFICO] Erro: $e");
    }

    return minutosPorDia.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsController>(context);
    final bool isDark = settings.isDarkMode;

    final Color bgMain = isDark
        ? const Color(0xFF1D0000)
        : const Color(0xFFEAFaf1);
    final Color cardBg = isDark ? const Color(0xFF2D0505) : Colors.white;
    final Color textMain = isDark ? Colors.white : Colors.black87;
    final Color textSec = isDark ? Colors.white70 : Colors.black54;
    final Color btnColor = isDark
        ? const Color(0xFFDA2B2B)
        : Colors.green[700]!;

    final List<BoxShadow>? shadowClara = isDark
        ? null
        : [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ];

    return Scaffold(
      backgroundColor: bgMain,
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore
            .collection('usuarios')
            .doc(widget.userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.red),
            );
          }

          var dados = snapshot.data!.data() as Map<String, dynamic>?;
          if (dados == null) {
            return Center(
              child: Text(
                "Usuário não encontrado",
                style: TextStyle(color: textMain),
              ),
            );
          }

          bool perfilPrivado = dados['perfil_privado'] ?? false;
          if (perfilPrivado) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, size: 80, color: textSec),
                  const SizedBox(height: 20),
                  Text(
                    "Este perfil é privado.",
                    style: TextStyle(
                      color: textMain,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: btnColor),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Voltar",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          String? fotoUrl = dados['url_perfil'];
          String corHex = dados['cor_hex'] ?? "#444444";
          String nome = dados['nome_exibicao'] ?? dados['nome'] ?? "Usuário";
          String bio = dados['bio'] ?? "Estudante no Studdy-Buddy";
          Color corDinamica = _hexToColor(corHex);

          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 260,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: corDinamica,
                            image: (fotoUrl != null && fotoUrl.isNotEmpty)
                                ? DecorationImage(
                                    image: _obterProvedorDeImagem(fotoUrl)!,
                                    fit: BoxFit.cover,
                                    opacity: 0.3,
                                  )
                                : null,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 40,
                        left: 20,
                        child: CircleAvatar(
                          backgroundColor: isDark
                              ? const Color(0xFFB30000)
                              : Colors.white,
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: isDark ? Colors.black : Colors.black87,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: shadowClara,
                          ),
                          child: CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 52,
                              backgroundColor: corDinamica,
                              backgroundImage: _obterProvedorDeImagem(fotoUrl),
                              child: (fotoUrl == null || fotoUrl.isEmpty)
                                  ? Text(
                                      nome.isNotEmpty
                                          ? nome[0].toUpperCase()
                                          : "?",
                                      style: const TextStyle(
                                        fontSize: 45,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  nome,
                  style: TextStyle(
                    color: textMain,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  bio,
                  style: TextStyle(color: textSec, fontSize: 14),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30),
                _buildSectionTitle("Atividade (Últimos 30 dias)", textMain),
                _buildGraficoMensal(corDinamica, isDark, cardBg, shadowClara),
                const SizedBox(height: 50),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );

  Widget _buildGraficoMensal(
    Color corBarras,
    bool isDark,
    Color cardBg,
    List<BoxShadow>? shadowClara,
  ) {
    return FutureBuilder<List<double>>(
      future: _processarTarefas(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: 240,
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(15),
              boxShadow: shadowClara,
            ),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.red),
            ),
          );
        }

        List<double> valores = snapshot.data ?? List.filled(30, 0.0);
        double maxMinutos = valores.reduce((a, b) => a > b ? a : b);
        if (maxMinutos == 0) maxMinutos = 1.0;

        DateTime agora = DateTime.now();
        DateTime hojeMeiaNoite = DateTime(agora.year, agora.month, agora.day);
        DateTime inicioFiltro = hojeMeiaNoite.subtract(
          const Duration(days: 29),
        );

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
          height: 240,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(15),
            boxShadow: shadowClara,
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.transparent,
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: valores.asMap().entries.map((entry) {
                int idx = entry.key;
                double v = entry.value;

                DateTime dataBarra = inicioFiltro.add(Duration(days: idx));
                String labelDia = DateFormat('dd/MM').format(dataBarra);
                double alturaCalculada = (v / maxMinutos) * 130;
                bool ehHoje =
                    dataBarra.day == agora.day &&
                    dataBarra.month == agora.month;

                return Container(
                  width: 48,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        v > 0 ? "${v.toInt()}m" : "-",
                        style: TextStyle(
                          color: v > 0
                              ? (isDark ? Colors.white : Colors.black87)
                              : (isDark ? Colors.white24 : Colors.black26),
                          fontSize: 10,
                          fontWeight: v > 0
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 8,
                        height: alturaCalculada > 0 ? alturaCalculada : 2,
                        decoration: BoxDecoration(
                          color: v > 0
                              ? corBarras
                              : (isDark ? Colors.white10 : Colors.black12),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        labelDia,
                        style: TextStyle(
                          color: ehHoje
                              ? corBarras
                              : (v > 0
                                    ? (isDark ? Colors.white70 : Colors.black87)
                                    : (isDark
                                          ? Colors.white38
                                          : Colors.black54)),
                          fontSize: 9,
                          fontWeight: ehHoje
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
