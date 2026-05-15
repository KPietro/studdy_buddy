import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
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

  final Color figmaVinhoEscuro = const Color(0xFF1D0000);
  final Color figmaInputFill = const Color(0xFF2D0505);
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

  void _mostrarSeletorCustomizado(Color corAtual) {
    Color corSelecionada = corAtual;

    showModalBottomSheet(
      context: context,
      backgroundColor: figmaVinhoEscuro,
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
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      "Personalizar Estilo",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildModalLabel("Avatar ou Galeria"),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 90,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          if (index == 0) return _buildGaleriaButton();
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
                                  color: Colors.white10,
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
                    _buildModalLabel("Cor de Identidade"),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: figmaInputFill,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Theme(
                        data: ThemeData.dark().copyWith(
                          inputDecorationTheme: InputDecorationTheme(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 12,
                            ),
                            filled: true,
                            fillColor: Colors.black26,
                            labelStyle: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
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
                              foregroundColor: Colors.white70,
                              side: const BorderSide(color: Colors.white24),
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
                              elevation: 0,
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

  Widget _buildGaleriaButton() {
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
          border: Border.all(color: Colors.white10, width: 2),
        ),
        child: const CircleAvatar(
          radius: 38,
          backgroundColor: Color(0xFF3A0A0A),
          child: Icon(
            Icons.add_photo_alternate,
            color: Colors.white70,
            size: 30,
          ),
        ),
      ),
    );
  }

  Widget _buildModalLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: Colors.white38,
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
      // Busca todas as tarefas que pertencem a este usuário nos últimos 30 dias
      // Usamos collectionGroup para vasculhar as subcoleções 'tarefas' dentro de qualquer grupo
      QuerySnapshot query = await _firestore
          .collectionGroup('tarefas')
          .where('criador_id', isEqualTo: user?.uid)
          .where('data_criacao', isGreaterThanOrEqualTo: inicioFiltro)
          .get();

      for (var doc in query.docs) {
        // Verifica se o ID do documento encontrado está na lista de tarefas_concluidas do usuário
        if (tarefasIds.contains(doc.id)) {
          var data = doc.data() as Map<String, dynamic>;
          Timestamp? ts = data['data_criacao'] as Timestamp?;

          if (ts != null) {
            DateTime dataCriacao = ts.toDate().toLocal();
            String diaFormatado = DateFormat('yyyy-MM-dd').format(dataCriacao);

            if (minutosPorDia.containsKey(diaFormatado)) {
              // Soma os minutos. Garantimos a conversão para double
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
    return Scaffold(
      backgroundColor: figmaVinhoEscuro,
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
                          backgroundColor: const Color(0xFFB30000),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: GestureDetector(
                          onTap: () => _mostrarSeletorCustomizado(corDinamica),
                          child: CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 52,
                              backgroundColor: corDinamica,
                              backgroundImage: _obterProvedorDeImagem(fotoUrl),
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
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                          ),
                          decoration: const InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                      )
                    : Text(
                        nome,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                const SizedBox(height: 30),
                _buildSectionTitle("Biografia"),
                _buildContainerBox(
                  isEditing: _isEditing,
                  child: TextField(
                    controller: _bioController,
                    enabled: _isEditing,
                    maxLines: 3,
                    style: TextStyle(
                      color: _isEditing ? Colors.white : Colors.white70,
                    ),
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
                          child: const Text("Salvar Alterações"),
                        )
                      : OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => setState(() => _isEditing = true),
                          child: const Text("Editar Perfil"),
                        ),
                ),

                _buildSectionTitle("Atividade (Últimos 30 dias)"),
                _buildGraficoMensal(corDinamica, tarefasIds),
                const SizedBox(height: 50),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );

  Widget _buildContainerBox({required Widget child, bool isEditing = false}) =>
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isEditing ? const Color(0xFF3A0A0A) : figmaInputFill,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isEditing ? botaoVermelho : Colors.white10),
        ),
        child: child,
      );

  Widget _buildGraficoMensal(Color corBarras, List<dynamic> tarefasIds) {
    return FutureBuilder<List<double>>(
      future: _processarTarefas(tarefasIds),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: 220,
            decoration: BoxDecoration(
              color: figmaInputFill,
              borderRadius: BorderRadius.circular(15),
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
            color: figmaInputFill,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white10),
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
                          color: v > 0 ? corBarras : Colors.white10,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const Divider(color: Colors.white10),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "30 dias atrás",
                    style: TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                  Text(
                    "Hoje",
                    style: TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
