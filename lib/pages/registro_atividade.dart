import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
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
  // --- CORES DO TEMA PREMIUM ---
  Color get bgMain =>
      widget.isDark ? const Color(0xFF1D0000) : const Color(0xFFEAFaf1);
  Color get textMain => widget.isDark ? Colors.white : Colors.black87;
  Color get pillBg => widget.isDark ? const Color(0xFF333333) : Colors.white;

  // --- SOMBRA SUAVE ---
  List<BoxShadow>? get shadowClara => widget.isDark
      ? null
      : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ];

  bool usarTimer = true;
  bool timerRodando = false;
  bool isSaving = false;

  Timer? _timer;
  int _segundosDecorridos = 0;

  final _acaoComumCtrl = TextEditingController();
  final _minutosComumCtrl = TextEditingController();
  final _descComumCtrl = TextEditingController();
  String? urlImagemComum;
  bool isUploadingComum = false;

  final _acaoMaiorCtrl = TextEditingController();
  final _minutosMaiorCtrl = TextEditingController();
  final _descMaiorCtrl = TextEditingController();
  String? urlImagemMaior;
  bool isUploadingMaior = false;

  @override
  void dispose() {
    _timer?.cancel();
    _acaoComumCtrl.dispose();
    _minutosComumCtrl.dispose();
    _descComumCtrl.dispose();
    _acaoMaiorCtrl.dispose();
    _minutosMaiorCtrl.dispose();
    _descMaiorCtrl.dispose();
    super.dispose();
  }

  void _iniciarOuPararTimer() {
    if (timerRodando) {
      _timer?.cancel();
      setState(() => timerRodando = false);
    } else {
      setState(() => timerRodando = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _segundosDecorridos++;
          });
        }
      });
    }
  }

  String _formatarTempo() {
    int h = _segundosDecorridos ~/ 3600;
    int m = (_segundosDecorridos % 3600) ~/ 60;
    int s = _segundosDecorridos % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

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
          const SnackBar(
            content: Text("Imagem anexada com sucesso!"),
            backgroundColor: Colors.green,
          ),
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

  Future<void> _salvarAtividade(String tipoTarefa) async {
    if (isSaving) return;

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

    if (acao.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Preencha a ação/título da atividade!"),
          backgroundColor: Colors.amber,
        ),
      );
      return;
    }

    if (tipoTarefa == "Tarefa Maior" && urlImagem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("A foto é obrigatória para a Tarefa Maior!"),
          backgroundColor: Colors.amber,
        ),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Usuário não logado.");

      int minutos = 0;

      if (tipoTarefa == "Comum" && usarTimer) {
        minutos = _segundosDecorridos > 0
            ? ((_segundosDecorridos + 59) ~/ 60)
            : 0;
      } else {
        minutos = int.tryParse(minStr) ?? 0;
      }

      if (minutos <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("A atividade precisa ter pelo menos 1 minuto!"),
            backgroundColor: Colors.amber,
          ),
        );
        setState(() => isSaving = false);
        return;
      }
      if (minutos > 10000) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("O limite máximo por atividade é de 10.000 minutos!"),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => isSaving = false);
        return;
      }

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();
      String nomeDoCriador = "Usuário";
      String fotoDoCriador = "";
      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;
        nomeDoCriador =
            userData['nome_exibicao'] ?? userData['nome'] ?? "Usuário";
        fotoDoCriador = userData['url_perfil'] ?? "";
      }

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

      int pontosGanhos = minutos * ptsPorMinuto;
      int incrementoAtividadeMaior = 0;

      if (tipoTarefa == "Tarefa Maior") {
        pontosGanhos += metaMaiorBonus;
        incrementoAtividadeMaior = 1;
      }

      final batch = FirebaseFirestore.instance.batch();

      var tarefaRef = FirebaseFirestore.instance
          .collection('grupos')
          .doc(widget.grupoId)
          .collection('tarefas')
          .doc();

      batch.set(tarefaRef, {
        'acao': acao,
        'descricao': desc,
        'minutos': minutos,
        'tipotarefa': tipoTarefa,
        'urlimagem': urlImagem ?? "",
        'criador_id': user.uid,
        'criador_nome': nomeDoCriador,
        'criador_foto': fotoDoCriador,
        'data_criacao': FieldValue.serverTimestamp(),
      });

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

      await batch.commit();

      if (mounted) {
        _timer?.cancel();
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: bgMain,
        appBar: AppBar(
          backgroundColor: widget.isDark
              ? const Color(0xFF4A0000)
              : Colors.green[700], // Verde mais elegante
          title: const Text(
            "Registrar Atividade",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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

          Container(
            decoration: BoxDecoration(
              color: pillBg,
              borderRadius: BorderRadius.circular(15),
              boxShadow: shadowClara, // Sombrinha suave!
              border: Border.all(
                color: widget.isDark ? Colors.white24 : Colors.transparent,
              ),
            ),
            child: SwitchListTile(
              title: Text(
                "Usar Cronômetro (Timer)",
                style: TextStyle(color: textMain, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "Desative para inserir tempo manual",
                style: TextStyle(
                  color: widget.isDark ? Colors.white60 : Colors.black54,
                  fontSize: 12,
                ),
              ),
              activeColor: widget.isDark ? Colors.red : Colors.green[700],
              value: usarTimer,
              onChanged: (val) {
                setState(() {
                  usarTimer = val;
                  if (!val) {
                    _timer?.cancel();
                    timerRodando = false;
                  }
                });
              },
            ),
          ),
          const SizedBox(height: 20),

          if (usarTimer)
            Center(
              child: Column(
                children: [
                  Text(
                    _formatarTempo(),
                    style: TextStyle(
                      color: textMain,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _iniciarOuPararTimer,
                    icon: Icon(
                      timerRodando ? Icons.stop : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    label: Text(
                      timerRodando ? "Parar Timer" : "Iniciar Timer",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: timerRodando
                          ? Colors.red
                          : (widget.isDark
                                ? Colors.red[900]
                                : Colors.green[700]),
                      elevation: widget.isDark ? 0 : 4,
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
              color: Colors.amber.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.shade700),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.amber.shade700),
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
        boxShadow: shadowClara, // Sombrinha no campo de texto!
        border: Border.all(
          color: widget.isDark ? Colors.white24 : Colors.transparent,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        style: TextStyle(color: textMain),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: widget.isDark ? Colors.grey : Colors.grey[500],
          ),
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
                  ? Colors.amber.shade700
                  : (widget.isDark ? Colors.red : Colors.green[700]),
            ),
      label: Text(
        isLoading ? "Enviando para a nuvem..." : texto,
        style: TextStyle(
          color: textMain,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: obrigatorio
              ? Colors.amber.shade700
              : (widget.isDark ? Colors.grey : Colors.grey.shade400),
        ),
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
          backgroundColor: widget.isDark ? Colors.red[700] : Colors.green[700],
          elevation: widget.isDark ? 0 : 5, // Destaque visual
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
