import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/imagem_controller.dart';

class CriacaoGrupoPage extends StatefulWidget {
  final bool isDark;

  const CriacaoGrupoPage({super.key, required this.isDark});

  @override
  State<CriacaoGrupoPage> createState() => _CriacaoGrupoPageState();
}

class _CriacaoGrupoPageState extends State<CriacaoGrupoPage> {
  final _nomeCtrl = TextEditingController();
  final _pontosMinutoCtrl = TextEditingController(text: "1");
  final _metaMaiorCtrl = TextEditingController(text: "50");

  String? urlFotoGrupo;
  bool isUploading = false;
  bool isSaving = false;

  Color get bgMain =>
      widget.isDark ? const Color(0xFF1D0000) : const Color(0xFFEAFaf1);
  Color get textMain => widget.isDark ? Colors.white : Colors.black;
  Color get pillBg => widget.isDark ? const Color(0xFF333333) : Colors.white;

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _pontosMinutoCtrl.dispose();
    _metaMaiorCtrl.dispose();
    super.dispose();
  }

  // --- LÓGICA DE UPLOAD DA FOTO DO GRUPO ---
  Future<void> _escolherImagem() async {
    setState(() => isUploading = true);

    String? link = await ImagemController.escolherESubirImagem();

    setState(() {
      if (link != null) urlFotoGrupo = link;
      isUploading = false;
    });

    if (mounted) {
      if (link != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Foto do grupo carregada!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Upload cancelado."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- LÓGICA DE CRIAÇÃO NO FIREBASE ---
  Future<void> _criarGrupo() async {
    if (_nomeCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("O nome do grupo é obrigatório!"),
          backgroundColor: Colors.amber,
        ),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Usuário não logado!");

      // 1. Busca os dados do criador (para ele já entrar no ranking com a foto certa)
      var userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();
      String nomeCriador = "Líder";
      String fotoCriador = "";
      if (userDoc.exists) {
        var data = userDoc.data() as Map<String, dynamic>;
        nomeCriador = data['nome_exibicao'] ?? data['nome'] ?? "Líder";
        fotoCriador = data['url_perfil'] ?? "";
      }

      int ptsMinuto = int.tryParse(_pontosMinutoCtrl.text) ?? 1;
      int metaMaior = int.tryParse(_metaMaiorCtrl.text) ?? 50;

      // 2. Cria o documento principal do Grupo
      var grupoRef = await FirebaseFirestore.instance.collection('grupos').add({
        'nome': _nomeCtrl.text.trim(),
        'foto_grupo': urlFotoGrupo ?? "",
        'pontos_por_minuto': ptsMinuto,
        'pontos_meta_maior': metaMaior,
        'membros_ids': [
          user.uid,
        ], // Já coloca você na lista de IDs pra aparecer na Home!
        'criador_id': user.uid,
        'data_criacao': FieldValue.serverTimestamp(),
      });

      // 3. Cria o perfil do criador dentro do Ranking (Coleção 'membros')
      await grupoRef.collection('membros').doc(user.uid).set({
        'nome': nomeCriador,
        'fotoPerfil': fotoCriador,
        'pontosSemanais': 0,
        'pontosTotais': 0,
        'atividadesMaioresSemanais': 0,
        'atividadesMaioresTotais': 0,
        'cargo': 'lider',
        'data_entrada': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Grupo criado com sucesso!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Volta para a tela anterior
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao criar: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  // --- WIDGETS DA TELA ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgMain,
      appBar: AppBar(
        backgroundColor: widget.isDark ? const Color(0xFF4A0000) : Colors.green,
        title: const Text(
          "Criar Novo Grupo",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),

            // --- FOTO DO GRUPO (CLICÁVEL) ---
            GestureDetector(
              onTap: isUploading ? null : _escolherImagem,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 65,
                    backgroundColor: widget.isDark
                        ? Colors.white10
                        : Colors.black12,
                    backgroundImage: urlFotoGrupo != null
                        ? CachedNetworkImageProvider(urlFotoGrupo!)
                        : null,
                    child: urlFotoGrupo == null
                        ? Icon(
                            Icons.groups,
                            size: 60,
                            color: textMain.withOpacity(0.5),
                          )
                        : null,
                  ),
                  if (isUploading)
                    const CircularProgressIndicator(color: Colors.greenAccent),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: widget.isDark ? Colors.red[700] : Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: bgMain, width: 3),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Text(
              "Foto do Grupo (Opcional)",
              style: TextStyle(color: textMain.withOpacity(0.6), fontSize: 14),
            ),
            const SizedBox(height: 35),

            // --- CAMPOS DE TEXTO ---
            _buildLabel("Nome do Grupo"),
            _buildTextField("Ex: Feras do ENEM, Devs de Sucesso...", _nomeCtrl),

            const SizedBox(height: 25),
            const Divider(color: Colors.grey),
            const SizedBox(height: 15),

            Text(
              "⚙️ Regras de Pontuação",
              style: TextStyle(
                color: textMain,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),

            _buildLabel("Pontos por minuto investido (Padrão: 1)"),
            _buildTextField("Ex: 1", _pontosMinutoCtrl, isNumber: true),

            const SizedBox(height: 15),

            _buildLabel("Bônus por Tarefa Maior (Padrão: 50 pts)"),
            _buildTextField("Ex: 50", _metaMaiorCtrl, isNumber: true),

            const SizedBox(height: 40),

            // --- BOTÃO DE CRIAR ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.isDark
                      ? Colors.red[700]
                      : Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: isSaving ? null : _criarGrupo,
                child: isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Criar Grupo",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: TextStyle(
            color: textMain,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    TextEditingController controller, {
    bool isNumber = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: pillBg,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: widget.isDark ? Colors.white24 : Colors.grey),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: TextStyle(color: textMain),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 15,
          ),
        ),
      ),
    );
  }
}
