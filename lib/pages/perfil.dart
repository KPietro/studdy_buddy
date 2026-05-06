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

  // Cores de Identidade Visual (Figma)
  final Color figmaVinhoEscuro = const Color(0xFF1D0000);
  final Color figmaInputFill = const Color(0xFF2D0505);
  final Color botaoVermelho = const Color(0xFFDA2B2B);

  // Converte Hexadecimal para Color
  Color _hexToColor(String hexCode) {
    try {
      String formattedHex = hexCode.replaceAll('#', '');
      if (formattedHex.length == 6) formattedHex = 'FF$formattedHex';
      return Color(int.parse('0x$formattedHex'));
    } catch (e) {
      return const Color(0xFF444444);
    }
  }

  // --- SELETOR DE AVATAR COM RODA DE CORES ---
  void _mostrarSeletorCustomizado(Color corAtual) {
    Color corSelecionada = corAtual;

    showModalBottomSheet(
      context: context,
      backgroundColor: figmaInputFill,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Personalizar Estilo",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Avatares Prontos
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Escolha um Avatar:", style: TextStyle(color: Colors.white70)),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 80,
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
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: CircleAvatar(
                          radius: 35,
                          backgroundImage: AssetImage(path),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const Divider(color: Colors.white10, height: 30),

              // Roda de Cores
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Cor de Fundo (Roda):", style: TextStyle(color: Colors.white70)),
              ),
              const SizedBox(height: 10),
              ColorPicker(
                pickerColor: corSelecionada,
                onColorChanged: (Color color) {
                  corSelecionada = color;
                },
                pickerAreaHeightPercent: 0.5,
                enableAlpha: false,
                displayThumbColor: true,
                paletteType: PaletteType.hsvWithHue,
                pickerAreaBorderRadius: const BorderRadius.all(Radius.circular(10)),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () {
                        _firestore.collection('usuarios').doc(user!.uid).update({
                          'url_perfil': '',
                        });
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.refresh, color: Colors.redAccent),
                      label: const Text("Usar Inicial", style: TextStyle(color: Colors.redAccent)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: botaoVermelho),
                    onPressed: () {
                      String hexString = '#${corSelecionada.value.toRadixString(16).substring(2).toUpperCase()}';
                      _firestore.collection('usuarios').doc(user!.uid).update({
                        'url_perfil': '', 
                        'cor_hex': hexString,
                      });
                      Navigator.pop(context);
                    },
                    child: const Text("Aplicar Cor"),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

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
            return const Center(child: CircularProgressIndicator());
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
                // HEADER COM CAPA E AVATAR
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
                            ? DecorationImage(
                                image: AssetImage(fotoUrl),
                                fit: BoxFit.cover,
                                opacity: 0.3,
                              )
                            : null,
                      ),
                    ),

                    // BOTÃO VOLTAR
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

                    // AVATAR
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
                            backgroundImage: (fotoUrl != null && fotoUrl.isNotEmpty)
                                ? AssetImage(fotoUrl)
                                : null,
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

                // NOME
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

                // SELO ALUNO PRATA
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(15)),
                  child: const Text("ALUNO PRATA", style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                ),

                const SizedBox(height: 30),

                _buildSectionTitle("Biografia"),

                // BIOGRAFIA COM CADEADO
                Stack(
                  children: [
                    _buildContainerBox(
                      isEditing: _isEditing,
                      child: TextField(
                        controller: _bioController,
                        enabled: _isEditing,
                        maxLines: 3,
                        style: TextStyle(color: _isEditing ? Colors.white : Colors.white70),
                        decoration: const InputDecoration(border: InputBorder.none, hintText: "Sua bio..."),
                      ),
                    ),
                    Positioned(
                      top: 15,
                      right: 35,
                      child: Icon(
                        _isEditing ? Icons.lock_open : Icons.lock,
                        color: _isEditing ? const Color(0xFF4CAF50) : Colors.white38,
                        size: 20,
                      ),
                    ),
                  ],
                ),

                // BOTÕES EDITAR/SALVAR CENTRALIZADOS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Center(
                    child: _isEditing 
                        ? ElevatedButton.icon(
                            onPressed: _salvarPerfil,
                            icon: const Icon(Icons.save, size: 16),
                            label: const Text("Salvar Perfil"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: botaoVermelho,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                            ),
                          )
                        : OutlinedButton.icon(
                            onPressed: () => setState(() => _isEditing = true),
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text("Editar Perfil"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white38),
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                            ),
                          ),
                  ),
                ),

                // NOVO GRÁFICO (Estilo 30 dias)
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

  Widget _buildContainerBox({required Widget child, double? height, bool isEditing = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(15),
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: isEditing ? const Color(0xFF3A0A0A) : figmaInputFill,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isEditing ? botaoVermelho : Colors.white10),
      ),
      child: child,
    );
  }

  // --- NOVO WIDGET: GRÁFICO DE 30 DIAS ---
  Widget _buildGraficoMensal(Color corBarras) {
    // Dados fictícios (mockup) baseados na sua imagem (valores de 0.0 a 1.0 onde 1.0 é 100%)
    final List<double> mockData = [
      0.35, 0.10, 0.55, 0.20, 0.15, 0.60, 0.25, 0.15, 0.35, 0.60, 
      0.10, 0.30, 0.50, 0.85, 1.00, 0.10, 0.25, 0.50, 0.15, 0.30, 
      0.45, 0.20, 0.25, 0.60, 0.30, 0.40, 0.55, 0.10, 0.35, 0.05
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.only(top: 20, bottom: 10, left: 10, right: 10),
      height: 250,
      decoration: BoxDecoration(
        color: figmaInputFill,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          // Eixo Y (Porcentagens)
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("100%", style: TextStyle(color: Colors.white54, fontSize: 10)),
              Text(" 75%", style: TextStyle(color: Colors.white54, fontSize: 10)),
              Text(" 50%", style: TextStyle(color: Colors.white54, fontSize: 10)),
              Text(" 25%", style: TextStyle(color: Colors.white54, fontSize: 10)),
              Text("  0%", style: TextStyle(color: Colors.white54, fontSize: 10)),
            ],
          ),
          const SizedBox(width: 10),
          
          // Área do Gráfico (Barras + Eixo X)
          Expanded(
            child: Column(
              children: [
                // Barras
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Calcula a largura de cada barra dinamicamente para caber na tela
                      double barWidth = (constraints.maxWidth / 30) - 2; 
                      if (barWidth < 2) barWidth = 2; // Tamanho mínimo

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: mockData.map((valor) {
                          return FractionallySizedBox(
                            heightFactor: valor, // A altura da barra é ditada por esse valor (0.0 a 1.0)
                            child: Container(
                              width: barWidth,
                              decoration: BoxDecoration(
                                color: corBarras, // A cor acompanha a identidade do perfil
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }
                  ),
                ),
                
                // Linha divisória do Eixo X
                Container(
                  height: 1,
                  color: Colors.white24,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                ),
                
                // Eixo X (Dias do mês - reduzido para não encavalar os números)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("1", style: TextStyle(color: Colors.white54, fontSize: 10)),
                    Text("5", style: TextStyle(color: Colors.white54, fontSize: 10)),
                    Text("10", style: TextStyle(color: Colors.white54, fontSize: 10)),
                    Text("15", style: TextStyle(color: Colors.white54, fontSize: 10)),
                    Text("20", style: TextStyle(color: Colors.white54, fontSize: 10)),
                    Text("25", style: TextStyle(color: Colors.white54, fontSize: 10)),
                    Text("30", style: TextStyle(color: Colors.white54, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}