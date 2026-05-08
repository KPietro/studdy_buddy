import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

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

  // Cores de Identidade Visual (Baseadas no Figma)
  final Color figmaVinhoEscuro = const Color(0xFF1D0000);
  final Color figmaInputFill = const Color(0xFF2D0505);
  final Color botaoVermelho = const Color(0xFFDA2B2B);

  // Converte Hexadecimal vindo do Firebase para Color do Flutter
  Color _hexToColor(String hexCode) {
    try {
      String formattedHex = hexCode.replaceAll('#', '');
      if (formattedHex.length == 6) formattedHex = 'FF$formattedHex';
      return Color(int.parse('0x$formattedHex'));
    } catch (e) {
      return const Color(0xFF444444); // Cor padrão caso falhe
    }
  }

  // --- SELETOR DE ESTILO (MODAL ORGANIZADO) ---
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
                    // Indicador visual de fechar modal
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
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 30),

                    // SEÇÃO 1: ESCOLHA DE AVATAR
                    _buildModalLabel("Escolha um Avatar"),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 90,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          String path = "assets/Avatares/Avatar${index + 1}.png";
                          return GestureDetector(
                            onTap: () {
                              _firestore.collection('usuarios').doc(user!.uid).update({
                                'url_perfil': path,
                              });
                              Navigator.pop(context);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 15),
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white10, width: 2),
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

                    const SizedBox(height: 35), // Espaçamento entre seções

                    // SEÇÃO 2: RODA DE CORES RGB/HEX
                    _buildModalLabel("Cor de Identidade (RGB)"),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: figmaInputFill,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Theme(
                        data: ThemeData.dark().copyWith(
                          inputDecorationTheme: InputDecorationTheme(
                            filled: true,
                            fillColor: Colors.black26,
                            labelStyle: const TextStyle(color: Colors.white),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        child: ColorPicker(
                          pickerColor: corSelecionada,
                          onColorChanged: (Color color) {
                            corSelecionada = color;
                          },
                          pickerAreaHeightPercent: 0.6,
                          enableAlpha: false,
                          displayThumbColor: true,
                          showLabel: true, // Habilita campos RGB/HEX
                          paletteType: PaletteType.hsvWithHue,
                          pickerAreaBorderRadius: const BorderRadius.all(Radius.circular(15)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // BOTÕES DE AÇÃO
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white70,
                              side: const BorderSide(color: Colors.white24),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              _firestore.collection('usuarios').doc(user!.uid).update({
                                'url_perfil': '', // Remove a imagem para usar a inicial
                              });
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
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              String hexString = '#${corSelecionada.value.toRadixString(16).substring(2).toUpperCase()}';
                              _firestore.collection('usuarios').doc(user!.uid).update({
                                'url_perfil': '', // Ao aplicar cor, priorizamos a cor de fundo + inicial
                                'cor_hex': hexString,
                              });
                              Navigator.pop(context);
                            },
                            child: const Text("Salvar Estilo", style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildModalLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1),
      ),
    );
  }

  // --- LÓGICA DE SALVAR NOME E BIO ---
  Future<void> _salvarPerfil() async {
    await _firestore.collection('usuarios').doc(user!.uid).update({
      'nome_exibicao': _nomeController.text.trim(),
      'bio': _bioController.text.trim(),
    });
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: figmaVinhoEscuro,
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('usuarios').doc(user!.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator(color: Colors.red));
          }

          var dados = snapshot.data!.data() as Map<String, dynamic>;
          String? fotoUrl = dados['url_perfil'];
          String corHex = dados['cor_hex'] ?? "#444444";
          String nome = dados['nome_exibicao'] ?? "Usuário";
          Color corDinamica = _hexToColor(corHex);

          if (!_isEditing) {
            _nomeController.text = nome;
            _bioController.text = dados['bio'] ?? "";
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // HEADER COM CAPA DINÂMICA
                Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: corDinamica,
                        image: (fotoUrl != null && fotoUrl.isNotEmpty)
                            ? DecorationImage(image: AssetImage(fotoUrl), fit: BoxFit.cover, opacity: 0.3)
                            : null,
                      ),
                    ),
                    Positioned(
                      top: 40,
                      left: 20,
                      child: CircleAvatar(
                        backgroundColor: const Color(0xFFB30000),
                        radius: 20,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                    // AVATAR EDITÁVEL
                    Positioned(
                      bottom: -50,
                      child: GestureDetector(
                        onTap: () => _mostrarSeletorCustomizado(corDinamica),
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 52,
                            backgroundColor: corDinamica,
                            backgroundImage: (fotoUrl != null && fotoUrl.isNotEmpty) ? AssetImage(fotoUrl) : null,
                            child: (fotoUrl == null || fotoUrl.isEmpty)
                                ? Text(
                                    nome.isNotEmpty ? nome[0].toUpperCase() : "?",
                                    style: const TextStyle(fontSize: 45, color: Colors.white, fontWeight: FontWeight.bold),
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 60),

                // NOME DO USUÁRIO
                _isEditing
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: TextField(
                          controller: _nomeController,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 22),
                          decoration: const InputDecoration(
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                          ),
                        ),
                      )
                    : Text(nome, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),

                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(15)),
                  child: const Text("ALUNO PRATA", style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                ),

                const SizedBox(height: 30),

                _buildSectionTitle("Biografia"),
                Stack(
                  children: [
                    _buildContainerBox(
                      isEditing: _isEditing,
                      child: TextField(
                        controller: _bioController,
                        enabled: _isEditing,
                        maxLines: 3,
                        style: TextStyle(color: _isEditing ? Colors.white : Colors.white70),
                        decoration: const InputDecoration(border: InputBorder.none, hintText: "Escreva algo sobre você..."),
                      ),
                    ),
                    Positioned(
                      top: 15,
                      right: 35,
                      child: Icon(_isEditing ? Icons.lock_open : Icons.lock, color: _isEditing ? Colors.green : Colors.white38, size: 18),
                    ),
                  ],
                ),

                // BOTÕES EDITAR/SALVAR
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: _isEditing
                      ? ElevatedButton.icon(
                          onPressed: _salvarPerfil,
                          icon: const Icon(Icons.save),
                          label: const Text("Salvar Alterações"),
                          style: ElevatedButton.styleFrom(backgroundColor: botaoVermelho, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12)),
                        )
                      : OutlinedButton.icon(
                          onPressed: () => setState(() => _isEditing = true),
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text("Editar Perfil"),
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white24)),
                        ),
                ),

                _buildSectionTitle("Atividade (Últimos 30 dias)"),
                _buildGraficoMensal(corDinamica),

                const SizedBox(height: 50),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildContainerBox({required Widget child, bool isEditing = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isEditing ? const Color(0xFF3A0A0A) : figmaInputFill,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isEditing ? botaoVermelho : Colors.white10),
      ),
      child: child,
    );
  }

  Widget _buildGraficoMensal(Color corBarras) {
    final List<double> mockData = [0.3, 0.1, 0.5, 0.2, 0.6, 0.8, 0.4, 0.2, 0.5, 0.7, 0.1, 0.4, 0.9, 1.0, 0.2, 0.3, 0.5, 0.6, 0.1, 0.4, 0.7, 0.2, 0.5, 0.8, 0.3, 0.4, 0.6, 0.2, 0.3, 0.1];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(15),
      height: 220,
      decoration: BoxDecoration(color: figmaInputFill, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white10)),
      child: Column(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: mockData.map((v) => Container(width: 6, height: v * 150, decoration: BoxDecoration(color: corBarras, borderRadius: BorderRadius.circular(2)))).toList(),
            ),
          ),
          const Divider(color: Colors.white10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text("1", style: TextStyle(color: Colors.white38, fontSize: 10)), Text("15", style: TextStyle(color: Colors.white38, fontSize: 10)), Text("30", style: TextStyle(color: Colors.white38, fontSize: 10))],
          )
        ],
      ),
    );
  }
}