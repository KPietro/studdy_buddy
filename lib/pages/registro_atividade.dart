import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/imagem_controller.dart';

class RegistroAtividadePage extends StatefulWidget {
  final bool isDark;
  final String grupoId;

  const RegistroAtividadePage({
    super.key,
    required this.isDark,
    required this.grupoId,
  });

  @override
  State<RegistroAtividadePage> createState() => _RegistroAtividadePageState();
}

class _RegistroAtividadePageState extends State<RegistroAtividadePage> {
  Color get bgMain =>
      widget.isDark ? const Color(0xFF1D0000) : const Color(0xFFEAFaf1);
  Color get textMain => widget.isDark ? Colors.white : Colors.black;
  Color get pillBg => widget.isDark ? const Color(0xFF333333) : Colors.white;

  bool usarTimer = true;
  bool timerRodando = false;
  bool isSaving = false;

  // Controladores para a Aba Comum
  final _acaoComumCtrl = TextEditingController();
  final _minutosComumCtrl = TextEditingController();
  final _descComumCtrl = TextEditingController();
  String? urlImagemComum;
  bool isUploadingComum = false;

  // Controladores para a Aba Maior
  final _acaoMaiorCtrl = TextEditingController();
  final _minutosMaiorCtrl = TextEditingController();
  final _descMaiorCtrl = TextEditingController();
  String? urlImagemMaior;
  bool isUploadingMaior = false;

  @override
  void dispose() {
    _acaoComumCtrl.dispose();
    _minutosComumCtrl.dispose();
    _descComumCtrl.dispose();
    _acaoMaiorCtrl.dispose();
    _minutosMaiorCtrl.dispose();
    _descMaiorCtrl.dispose();
    super.dispose();
  }

  // --- LÓGICA DE UPLOAD (MANTIDA DA SUA VERSÃO) ---

  Future<void> _escolherImagem(String tipo) async {
    setState(() {
      if (tipo == "Comum") isUploadingComum = true;
      if (tipo == "Maior") isUploadingMaior = true;
    });

    String? link = await ImagemController.escolherESubirImagem();

    setState(() {
      if (tipo == "Comum") {
        if (link != null) urlImagemComum = link;
        isUploadingComum = false;
      }
      if (tipo == "Maior") {
        if (link != null) urlImagemMaior = link;
        isUploadingMaior = false;
      }
    });

    if (mounted) {
      if (link != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Imagem anexada com sucesso!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cancelado ou erro de conexão."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- LÓGICA DE SALVAR (FUNDIDA COM A DO BRAYAN) ---

  Future<void> _salvarAtividade(String tipoTarefa) async {
    if (isSaving) return;

    // Coleta os dados dependendo da aba que você está usando
    String acao = tipoTarefa == "Comum"
        ? _acaoComumCtrl.text
        : _acaoMaiorCtrl.text;
    String desc = tipoTarefa == "Comum"
        ? _descComumCtrl.text
        : _descMaiorCtrl.text;
    String minStr = tipoTarefa == "Comum"
        ? _minutosComumCtrl.text
        : _minutosMaiorCtrl.text;
    String? urlImagem = tipoTarefa == "Comum" ? urlImagemComum : urlImagemMaior;

    // Validações
    if (acao.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha a ação/título da atividade!")),
      );
      return;
    }

    if (tipoTarefa == "Tarefa Maior" && urlImagem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("A foto é obrigatória para a Tarefa Maior!"),
        ),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Usuário não logado.");

      // Converte minutos (se usou timer, coloca 30 min provisório para não quebrar a lógica)
      num minutos =
          num.tryParse(minStr) ?? (usarTimer && tipoTarefa == "Comum" ? 30 : 0);

      // 1. LER AS REGRAS DO GRUPO (quantos pontos vale cada minuto) - Lógica do Brayan
      DocumentSnapshot grupoDoc = await FirebaseFirestore.instance
          .collection('grupos')
          .doc(widget.grupoId)
          .get();
      var dadosGrupo = grupoDoc.data() as Map<String, dynamic>?;

      int ptsPorMinuto = 1;
      int metaMaiorBonus = 0;
      if (dadosGrupo != null) {
        ptsPorMinuto =
            (dadosGrupo['pontos_por_minuto'] ??
                    dadosGrupo['pontos_minuto'] ??
                    1)
                .toInt();
        metaMaiorBonus =
            (dadosGrupo['pontos_meta_maior'] ?? dadosGrupo['meta_maior'] ?? 0)
                .toInt();
      }

      // 2. CÁLCULO DOS PONTOS - Lógica do Brayan
      int pontosGanhos = (minutos.toInt()) * ptsPorMinuto;
      int incrementoAtividadeMaior = 0;

      if (tipoTarefa == "Tarefa Maior") {
        pontosGanhos += metaMaiorBonus;
        incrementoAtividadeMaior = 1;
      }

      // 3. USANDO O BATCH (TUDO OU NADA) - Lógica do Brayan
      final batch = FirebaseFirestore.instance.batch();

      // A. Prepara a gravação da Tarefa
      var tarefaRef = FirebaseFirestore.instance
          .collection('grupos')
          .doc(widget.grupoId)
          .collection('tarefas')
          .doc(); // Gera o ID único da tarefa

      batch.set(tarefaRef, {
        'acao': acao,
        'descricao': desc,
        'minutos': minutos,
        'tipotarefa': tipoTarefa, // Salva se é Comum ou Tarefa Maior
        'urlimagem': urlImagem ?? "", // Imagem da sua lógica!
        'criador_id': user.uid,
        'data_criacao': FieldValue.serverTimestamp(),
      });

      // B. Prepara a atualização dos Pontos do Membro
      var membroRef = FirebaseFirestore.instance
          .collection('grupos')
          .doc(widget.grupoId)
          .collection('membros')
          .doc(user.uid);

      batch.update(membroRef, {
        'pontosSemanais': FieldValue.increment(pontosGanhos),
        'pontosTotais': FieldValue.increment(pontosGanhos),
        'atividadesMaioresSemanais': FieldValue.increment(
          incrementoAtividadeMaior,
        ),
        'atividadesMaioresTotais': FieldValue.increment(
          incrementoAtividadeMaior,
        ),
      });

      // C. Executa as duas operações juntas instantaneamente
      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Atividade enviada e pontos computados!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao salvar: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  // --- UI (MANTIDA EXATAMENTE A SUA) ---

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
            "Registrar Atividade",
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(text: "Atividade Comum", icon: Icon(Icons.timer)),
              Tab(text: "Tarefa Maior", icon: Icon(Icons.workspace_premium)),
            ],
          ),
        ),
        body: TabBarView(children: [_buildAbaComum(), _buildAbaMaior()]),
      ),
    );
  }

  Widget _buildAbaComum() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel("O que você está fazendo?"),
          _buildTextField(
            "Ex: Lendo capítulo 4 de História",
            controller: _acaoComumCtrl,
          ),
          const SizedBox(height: 20),

          // Toggle Timer vs Manual
          Container(
            decoration: BoxDecoration(
              color: pillBg,
              borderRadius: BorderRadius.circular(15),
            ),
            child: SwitchListTile(
              title: Text(
                "Usar Cronômetro (Timer)",
                style: TextStyle(color: textMain, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "Desative para inserir tempo manual",
                style: TextStyle(
                  color: textMain.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
              activeColor: widget.isDark ? Colors.red : Colors.green,
              value: usarTimer,
              onChanged: (val) => setState(() => usarTimer = val),
            ),
          ),
          const SizedBox(height: 20),

          if (usarTimer)
            Center(
              child: Column(
                children: [
                  Text(
                    "00:00:00",
                    style: TextStyle(
                      color: textMain,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () =>
                        setState(() => timerRodando = !timerRodando),
                    icon: Icon(
                      timerRodando ? Icons.stop : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    label: Text(
                      timerRodando ? "Parar Timer" : "Iniciar Timer",
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: timerRodando
                          ? Colors.red
                          : (widget.isDark ? Colors.red[900] : Colors.green),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel("Tempo investido (em minutos)"),
                _buildTextField(
                  "Ex: 45",
                  isNumber: true,
                  controller: _minutosComumCtrl,
                ),
              ],
            ),

          const SizedBox(height: 30),
          _buildBotaoUpload(
            urlImagemComum == null
                ? "Adicionar Foto / Print (Opcional)"
                : "Imagem Anexada!",
            urlImagemComum == null ? Icons.add_a_photo : Icons.check_circle,
            isLoading: isUploadingComum,
            onPressed: () => _escolherImagem("Comum"),
          ),
          const SizedBox(height: 10),
          _buildTextField(
            "Descrição opcional...",
            maxLines: 3,
            controller: _descComumCtrl,
          ),
          const SizedBox(height: 30),
          _buildBotaoEnviar("Enviar Atividade", "Comum"),
        ],
      ),
    );
  }

  Widget _buildAbaMaior() {
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
                const Icon(Icons.warning_amber_rounded, color: Colors.amber),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Tarefas maiores exigem comprovação! Foto e descrição detalhada são obrigatórios.",
                    style: TextStyle(color: textMain, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _buildLabel("Qual foi a Tarefa Maior?"),
          _buildTextField(
            "Ex: Simulado ENEM do cursinho",
            controller: _acaoMaiorCtrl,
          ),

          _buildLabel("Tempo investido (em minutos)"),
          _buildTextField(
            "Ex: 240",
            isNumber: true,
            controller: _minutosMaiorCtrl,
          ),

          const SizedBox(height: 20),
          _buildBotaoUpload(
            urlImagemMaior == null
                ? "Adicionar Foto/Print (OBRIGATÓRIO)"
                : "Imagem Anexada!",
            urlImagemMaior == null ? Icons.camera_alt : Icons.check_circle,
            obrigatorio: urlImagemMaior == null,
            isLoading: isUploadingMaior,
            onPressed: () => _escolherImagem("Maior"),
          ),

          const SizedBox(height: 15),
          _buildLabel("Descrição (OBRIGATÓRIO)"),
          _buildTextField(
            "Explique suas dificuldades e o que achou da tarefa...",
            maxLines: 4,
            controller: _descMaiorCtrl,
          ),

          const SizedBox(height: 30),
          _buildBotaoEnviar("Enviar Atividade", "Tarefa Maior"),
        ],
      ),
    );
  }

  // --- Widgets Auxiliares ---
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
    String hint, {
    bool isNumber = false,
    int maxLines = 1,
    TextEditingController? controller,
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
        maxLines: maxLines,
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

  Widget _buildBotaoUpload(
    String texto,
    IconData icone, {
    bool obrigatorio = false,
    bool isLoading = false,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Icon(
              icone,
              color: obrigatorio
                  ? Colors.amber
                  : (widget.isDark ? Colors.red : Colors.green),
            ),
      label: Text(
        isLoading ? "Enviando para a nuvem..." : texto,
        style: TextStyle(color: textMain, fontSize: 12),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: obrigatorio ? Colors.amber : Colors.grey),
        padding: const EdgeInsets.all(15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  Widget _buildBotaoEnviar(String textoBotao, String tipoTarefa) {
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
        onPressed: isSaving ? null : () => _salvarAtividade(tipoTarefa),
        child: isSaving
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                textoBotao,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
