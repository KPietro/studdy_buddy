import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CriacaoGrupoPage extends StatefulWidget {
  final bool isDark;
  const CriacaoGrupoPage({super.key, required this.isDark});

  @override
  State<CriacaoGrupoPage> createState() => _CriacaoGrupoPageState();
}

class _CriacaoGrupoPageState extends State<CriacaoGrupoPage> {
  Color get bgMain =>
      widget.isDark ? const Color(0xFF1D0000) : const Color(0xFFEAFaf1);
  Color get textMain => widget.isDark ? Colors.white : Colors.black;
  Color get pillBg => widget.isDark ? const Color(0xFF333333) : Colors.white;

  final nomeController = TextEditingController();
  final pontosMinutoController = TextEditingController(text: "1");
  final metaMaiorController = TextEditingController();
  final tituloSemanalController = TextEditingController();
  final tituloTotalController = TextEditingController();

  bool isLoading = false; // Variável para controlar o botão de loading

  // --- NOVA FUNÇÃO: LIGAÇÃO REAL AO FIREBASE ---
  Future<void> _criarGrupo() async {
    if (nomeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("O nome do grupo é obrigatório!")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      // 1. Cria o documento do Grupo na coleção 'grupos'
      DocumentReference novoGrupoRef = await FirebaseFirestore.instance
          .collection('grupos')
          .add({
            'nome': nomeController.text.trim(),
            'pontos_minuto':
                int.tryParse(pontosMinutoController.text.trim()) ?? 1,
            'meta_maior': int.tryParse(metaMaiorController.text.trim()) ?? 0,
            'titulo_semanal': tituloSemanalController.text.trim(),
            'titulo_total': tituloTotalController.text.trim(),
            'criador_id': user?.uid,
            'data_criacao': FieldValue.serverTimestamp(),
          });

      // 2. Adiciona o utilizador atual como o primeiro membro na subcoleção 'membros'
      if (user != null) {
        // Vai buscar o nome e foto do utilizador para guardar no grupo
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .get();
        String nomeExibicao = "Líder";
        String fotoUrl = "";

        if (userDoc.exists) {
          var dados = userDoc.data() as Map<String, dynamic>;
          nomeExibicao = dados['nome_exibicao'] ?? dados['nome'] ?? "Líder";
          fotoUrl = dados['url_perfil'] ?? dados['foto_url'] ?? "";
        }

        await novoGrupoRef.collection('membros').doc(user.uid).set({
          'nome': nomeExibicao,
          'fotoPerfil': fotoUrl,
          'pontosSemanais': 0,
          'pontosTotais': 0,
          'atividadesMaioresSemanais': 0,
          'atividadesMaioresTotais': 0,
          'cargo': 'admin', // Identifica o criador do grupo
          'data_entrada': FieldValue.serverTimestamp(),
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Grupo criado com sucesso!")),
        );
        Navigator.pop(context); // Regressa à HomePage
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erro ao criar o grupo. Tente novamente."),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: bgMain,
        appBar: AppBar(
          backgroundColor: widget.isDark
              ? const Color(0xFF4A0000)
              : Colors.green,
          title: const Text(
            "Criar Novo Grupo",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(text: "Config. Básica", icon: Icon(Icons.settings)),
              Tab(text: "Medalhas", icon: Icon(Icons.military_tech)),
            ],
          ),
        ),
        body: TabBarView(children: [_buildAbaBasico(), _buildAbaMedalhas()]),
      ),
    );
  }

  Widget _buildAbaBasico() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel("Nome do Grupo"),
          _buildTextField(nomeController, "Ex: Os Aprovados"),

          _buildLabel("Pontos por minuto investido (Padrão: 1)"),
          _buildTextField(pontosMinutoController, "1", isNumber: true),

          _buildLabel("Pontos de uma Meta Maior (Ex: Simulado)"),
          _buildTextField(metaMaiorController, "Ex: 500", isNumber: true),

          const SizedBox(height: 40),
          _buildBotaoCriar(),
        ],
      ),
    );
  }

  Widget _buildAbaMedalhas() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber),
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_events, color: Colors.amber),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Estes nomes aparecerão no ranking. O criador ou líder pode alterar depois.",
                    style: TextStyle(color: textMain, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _buildLabel("Título do Top 1 Semanal"),
          _buildTextField(tituloSemanalController, "Ex: O Sabichão da Semana"),

          _buildLabel("Título do Top 1 Total"),
          _buildTextField(tituloTotalController, "Ex: O Grande Mestre"),

          const SizedBox(height: 40),
          _buildBotaoCriar(),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 15),
      child: Text(
        text,
        style: TextStyle(
          color: textMain,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
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

  Widget _buildBotaoCriar() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.isDark ? Colors.red[700] : Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        // Agora o botão chama a nossa função de criar com o Firebase!
        onPressed: isLoading ? null : _criarGrupo,
        child: isLoading
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
    );
  }
}
