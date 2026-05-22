import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // <-- Adicionado para ler o tema
import '../controllers/settings_controller.dart'; // <-- Adicionado para ler o tema
import '../controllers/imagem_controller.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isEditing = false;
  bool _isUploadingAvatar = false;

  final Color botaoVermelho = const Color(0xFFDA2B2B);

  // --- LÓGICA DE IMAGEM ---

  Future<void> _escolherFotoGaleria() async {
    setState(() => _isUploadingAvatar = true);
    String? link = await ImagemController.escolherESubirImagem();

    if (link != null) {
      await _firestore.collection('usuarios').doc(user!.uid).update({
        'url_perfil': link,
      });
    }
    if (mounted) setState(() => _isUploadingAvatar = false);
  }

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

  // --- SELETOR DE ESTILO REFORMULADO ---

  void _mostrarSeletorCustomizado(Color corAtual, bool isDark) {
    Color corSelecionada = corAtual;

    // Cores do modal baseadas no tema
    Color modalBg = isDark ? const Color(0xFF1D0000) : const Color(0xFFEAFaf1);
    Color modalText = isDark ? Colors.white : Colors.black87;
    Color modalContainer = isDark ? const Color(0xFF2D0505) : Colors.white;

    showModalBottomSheet(
      context: context,
      backgroundColor: modalBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Text(
                      "Personalizar Estilo",
                      style: TextStyle(
                        color: modalText,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildModalLabel("Avatar ou Galeria", isDark),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 90,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          if (index == 0) return _buildGaleriaButton(isDark);
                          String path = "assets/Avatares/Avatar$index.png";
                          return GestureDetector(
                            onTap: () {
                              _firestore
                                  .collection('usuarios')
                                  .doc(user!.uid)
                                  .update({'url_perfil': path});
                              Navigator.pop(context);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 15),
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white10
                                      : Colors.black12,
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 38,
                                backgroundImage: AssetImage(path),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildModalLabel("Cor de Identidade", isDark),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: modalContainer,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? Colors.white10 : Colors.transparent,
                        ),
                        boxShadow: isDark
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: Theme(
                        data: isDark ? ThemeData.dark() : ThemeData.light(),
                        child: ColorPicker(
                          pickerColor: corSelecionada,
                          onColorChanged: (Color color) {
                            setModalState(() => corSelecionada = color);
                          },
                          paletteType: PaletteType.hsvWithHue,
                          pickerAreaHeightPercent: 0.6,
                          enableAlpha: false,
                          displayThumbColor: false,
                          showLabel: true,
                          portraitOnly: true,
                          pickerAreaBorderRadius: const BorderRadius.all(
                            Radius.circular(15),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: modalText,
                              side: BorderSide(
                                color: isDark ? Colors.white24 : Colors.black26,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              _firestore
                                  .collection('usuarios')
                                  .doc(user!.uid)
                                  .update({'url_perfil': ''});
                              Navigator.pop(context);
                            },
                            child: const Text("Usar Inicial"),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: botaoVermelho,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: isDark ? 0 : 3,
                            ),
                            onPressed: () {
                              String hexString =
                                  '#${corSelecionada.value.toRadixString(16).substring(2).toUpperCase()}';
                              _firestore
                                  .collection('usuarios')
                                  .doc(user!.uid)
                                  .update({'cor_hex': hexString});
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Salvar Estilo",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGaleriaButton(bool isDark) {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);
        await _escolherFotoGaleria();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black12,
            width: 2,
          ),
        ),
        child: CircleAvatar(
          radius: 38,
          backgroundColor: isDark ? const Color(0xFF3A0A0A) : Colors.grey[200],
          child: Icon(
            Icons.add_photo_alternate,
            color: isDark ? Colors.white70 : Colors.black54,
            size: 30,
          ),
        ),
      ),
    );
  }

  Widget _buildModalLabel(String text, bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: isDark ? Colors.white38 : Colors.black45,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // --- LÓGICA DO GRÁFICO (PROCESSAMENTO REAL) ---

  Future<List<double>> _processarTarefas(List<dynamic> tarefasIds) async {
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

    if (tarefasIds.isEmpty) return minutosPorDia.values.toList();

    try {
      QuerySnapshot query = await _firestore
          .collectionGroup('tarefas')
          .where('criador_id', isEqualTo: user?.uid)
          .where('data_criacao', isGreaterThanOrEqualTo: inicioFiltro)
          .get();

      for (var doc in query.docs) {
        if (tarefasIds.contains(doc.id)) {
          var data = doc.data() as Map<String, dynamic>;
          Timestamp? ts = data['data_criacao'] as Timestamp?;

          if (ts != null) {
            DateTime dataCriacao = ts.toDate().toLocal();
            String diaFormatado = DateFormat('yyyy-MM-dd').format(dataCriacao);

            if (minutosPorDia.containsKey(diaFormatado)) {
              double valorMinutos =
                  double.tryParse(data['minutos'].toString()) ?? 0.0;
              minutosPorDia[diaFormatado] =
                  minutosPorDia[diaFormatado]! + valorMinutos;
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Erro ao processar gráfico: $e");
    }

    return minutosPorDia.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    // Puxando o tema em tempo real
    final isDark = Provider.of<SettingsController>(context).isDarkMode;

    // Cores Dinâmicas do Tema Premium
    final Color bgMain = isDark
        ? const Color(0xFF1D0000)
        : const Color(0xFFEAFaf1);
    final Color containerBg = isDark ? const Color(0xFF2D0505) : Colors.white;
    final Color textMain = isDark ? Colors.white : Colors.black87;
    final Color textSec = isDark ? Colors.white70 : Colors.black54;
    final Color dividerCor = isDark ? Colors.white10 : Colors.black12;
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
        stream: _firestore.collection('usuarios').doc(user!.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          var dados = snapshot.data!.data() as Map<String, dynamic>;
          String? fotoUrl = dados['url_perfil'];
          String corHex = dados['cor_hex'] ?? "#444444";
          String nome = dados['nome_exibicao'] ?? "Usuário";
          Color corDinamica = _hexToColor(corHex);
          List<dynamic> tarefasIds = dados['tarefas_concluidas'] ?? [];

          if (!_isEditing) {
            _nomeController.text = nome;
            _bioController.text = dados['bio'] ?? "";
          }

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
                        child: GestureDetector(
                          onTap: () =>
                              _mostrarSeletorCustomizado(corDinamica, isDark),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow:
                                  shadowClara, // Sombra no avatar principal
                            ),
                            child: CircleAvatar(
                              radius: 55,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 52,
                                backgroundColor: corDinamica,
                                backgroundImage: _obterProvedorDeImagem(
                                  fotoUrl,
                                ),
                                child: _isUploadingAvatar
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : (fotoUrl == null || fotoUrl.isEmpty)
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
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _isEditing
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: TextField(
                          controller: _nomeController,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: textMain, fontSize: 22),
                          decoration: const InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                      )
                    : Text(
                        nome,
                        style: TextStyle(
                          color: textMain,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                const SizedBox(height: 30),
                _buildSectionTitle("Biografia", textMain),
                _buildContainerBox(
                  isEditing: _isEditing,
                  isDark: isDark,
                  containerBg: containerBg,
                  shadowClara: shadowClara,
                  child: TextField(
                    controller: _bioController,
                    enabled: _isEditing,
                    maxLines: 3,
                    style: TextStyle(color: _isEditing ? textMain : textSec),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Escreva algo...",
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: _isEditing
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: botaoVermelho,
                            elevation: isDark ? 0 : 3,
                          ),
                          onPressed: () async {
                            await _firestore
                                .collection('usuarios')
                                .doc(user!.uid)
                                .update({
                                  'nome_exibicao': _nomeController.text.trim(),
                                  'bio': _bioController.text.trim(),
                                });
                            setState(() => _isEditing = false);
                          },
                          child: const Text(
                            "Salvar Alterações",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: textMain,
                            side: BorderSide(color: dividerCor),
                          ),
                          onPressed: () => setState(() => _isEditing = true),
                          child: const Text("Editar Perfil"),
                        ),
                ),

                _buildSectionTitle("Atividade (Últimos 30 dias)", textMain),
                _buildGraficoMensal(
                  corDinamica,
                  tarefasIds,
                  containerBg,
                  dividerCor,
                  textSec,
                  shadowClara,
                ),
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

  Widget _buildContainerBox({
    required Widget child,
    required bool isEditing,
    required bool isDark,
    required Color containerBg,
    required List<BoxShadow>? shadowClara,
  }) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: isEditing
          ? (isDark ? const Color(0xFF3A0A0A) : Colors.red[50])
          : containerBg,
      borderRadius: BorderRadius.circular(15),
      boxShadow: shadowClara,
      border: Border.all(
        color: isEditing
            ? botaoVermelho
            : (isDark ? Colors.white10 : Colors.transparent),
      ),
    ),
    child: child,
  );

  Widget _buildGraficoMensal(
    Color corBarras,
    List<dynamic> tarefasIds,
    Color containerBg,
    Color dividerCor,
    Color textSec,
    List<BoxShadow>? shadowClara,
  ) {
    return FutureBuilder<List<double>>(
      future: _processarTarefas(tarefasIds),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: 220,
            decoration: BoxDecoration(
              color: containerBg,
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

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(15),
          height: 220,
          decoration: BoxDecoration(
            color: containerBg,
            borderRadius: BorderRadius.circular(15),
            boxShadow: shadowClara,
            border: Border.all(color: dividerCor),
          ),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: valores.map((v) {
                    double altura = (v / maxMinutos) * 150;
                    return Tooltip(
                      message: "${v.toInt()} min",
                      child: Container(
                        width: 6,
                        height: altura > 0 ? altura : 2,
                        decoration: BoxDecoration(
                          color: v > 0 ? corBarras : dividerCor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Divider(color: dividerCor),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "30 dias atrás",
                    style: TextStyle(color: textSec, fontSize: 10),
                  ),
                  Text("Hoje", style: TextStyle(color: textSec, fontSize: 10)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
