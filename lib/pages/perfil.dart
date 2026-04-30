import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  // Cores de Identidade Visual (Figma) mantidas intactas
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

  // --- SELETOR DE AVATAR / COR / REMOVER FOTO ---
  void _mostrarSeletorCustomizado() {
    TextEditingController hexInputController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: figmaInputFill,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Personalizar Estilo",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Avatares
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Escolha um Avatar:",
                  style: TextStyle(color: Colors.white70),
                ),
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
                        _firestore.collection('usuarios').doc(user!.uid).update(
                          {'url_perfil': path},
                        );
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

              // Cor Hexadecimal
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Cor de Fundo (Hex):",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: hexInputController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "#FF0000",
                        hintStyle: const TextStyle(color: Colors.white24),
                        filled: true,
                        fillColor: Colors.black26,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                    ),
                    onPressed: () {
                      _firestore.collection('usuarios').doc(user!.uid).update({
                        'url_perfil': '', // LIMPA A FOTO PARA VOLTAR A LETRA
                        'cor_hex': hexInputController.text.isNotEmpty
                            ? hexInputController.text.trim()
                            : "#444444",
                      });
                      Navigator.pop(context);
                    },
                    child: const Text("Aplicar"),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // BOTÃO PARA VOLTAR À INICIAL (REMOVER FOTO)
              TextButton.icon(
                onPressed: () {
                  _firestore.collection('usuarios').doc(user!.uid).update({
                    'url_perfil': '',
                  });
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
                label: const Text(
                  "Remover Foto (Usar Inicial)",
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
              const SizedBox(height: 30),
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
          if (!snapshot.hasData || !snapshot.data!.exists)
            return const Center(child: CircularProgressIndicator());

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
                // HEADER COM CAPA, FOTO E BOTÃO DE VOLTAR
                Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Capa de Fundo
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

                    // BOTÃO DE VOLTAR (Estilo Ranking)
                    Positioned(
                      top:
                          40, // Margem segura para não ficar em cima da barra de status do celular
                      left: 20,
                      child: CircleAvatar(
                        backgroundColor: const Color(0xFFB30000),
                        radius: 20,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),

                    // Avatar do Usuário
                    Positioned(
                      bottom: -50,
                      child: GestureDetector(
                        onTap: _mostrarSeletorCustomizado,
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 52,
                            backgroundColor: corDinamica,
                            backgroundImage:
                                (fotoUrl != null && fotoUrl.isNotEmpty)
                                ? AssetImage(fotoUrl)
                                : null,
                            child: (fotoUrl == null || fotoUrl.isEmpty)
                                ? Text(
                                    nome[0].toUpperCase(),
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

                const SizedBox(height: 60),
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

                // SELO ALUNO PRATA
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Text(
                    "ALUNO PRATA",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                _buildSectionTitle("Biografia"),

                // --- ÁREA DA BIOGRAFIA COM CADEADO ---
                Stack(
                  children: [
                    _buildContainerBox(
                      isEditing: _isEditing, // Aplica o efeito visual aqui
                      child: TextField(
                        controller: _bioController,
                        enabled: _isEditing,
                        maxLines: 3,
                        style: TextStyle(
                          color: _isEditing ? Colors.white : Colors.white70,
                        ), // Efeito no texto
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Sua bio...",
                        ),
                      ),
                    ),
                    // O CADEADO NO CANTO SUPERIOR DIREITO DA CAIXA
                    Positioned(
                      top: 15,
                      right: 35,
                      child: Icon(
                        _isEditing ? Icons.lock_open : Icons.lock,
                        color: _isEditing
                            ? const Color(0xFF4CAF50)
                            : Colors.white38,
                        size: 20,
                      ),
                    ),
                  ],
                ),

                // --- BOTÕES DE EDITAR E SALVAR ---
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Botão Editar
                      OutlinedButton.icon(
                        onPressed: _isEditing
                            ? null
                            : () => setState(() => _isEditing = true),
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text("Editar"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.white38,
                          side: BorderSide(
                            color: _isEditing
                                ? Colors.transparent
                                : Colors.white38,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Botão Salvar
                      ElevatedButton.icon(
                        onPressed: _isEditing ? _salvarPerfil : null,
                        icon: const Icon(Icons.save, size: 16),
                        label: const Text("Salvar"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: botaoVermelho,
                          disabledBackgroundColor: Colors.white10,
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ),

                // RESTAURAÇÃO DOS GRÁFICOS (ATIVIDADE SEMANAL)
                _buildSectionTitle("Atividade Semanal"),
                _buildContainerBox(
                  height: 150,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(
                      10,
                      (index) => Container(
                        width: 15,
                        height: (index % 5 + 3) * 12.0,
                        decoration: BoxDecoration(
                          color: corDinamica,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                ),
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
  }

  // --- FUNÇÃO _buildContainerBox MODIFICADA PARA EFEITOS VISUAIS ---
  Widget _buildContainerBox({
    required Widget child,
    double? height,
    bool isEditing = false,
  }) {
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
}
