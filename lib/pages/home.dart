import 'package:flutter/material.dart';

// 📦 MODELO DE DADOS
class Grupo {
  final String nome;
  final List<String> mensagens;

  Grupo(this.nome, this.mensagens);
}

// 🏠 HOME
class HomePage extends StatefulWidget {
  final bool isDark;

  const HomePage({super.key, required this.isDark});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late bool isDark;

  @override
  void initState() {
    super.initState();
    isDark = widget.isDark;
  }

  // 🔥 LISTA DE GRUPOS (fake por enquanto)
  List<Grupo> grupos = [
    Grupo("G1", ["Prova amanhã", "Resumo cap 2", "Trabalho grupo"]),
    Grupo("G2", ["Revisar matemática", "Lista exercícios", "Dúvida aula"]),
    Grupo("G3", ["História prova", "Resumo guerra", "Atividade"]),
  ];

  List<Map<String, dynamic>> recentes = [];
  List<Map<String, dynamic>> filtrados = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    gerarRecentes();
  }

  void gerarRecentes() {
    recentes.clear();
    for (var grupo in grupos) {
      for (var msg in grupo.mensagens) {
        recentes.add({"grupo": grupo.nome, "mensagem": msg});
      }
    }
    filtrados = List.from(recentes);
  }

  void buscar(String texto) {
    setState(() {
      filtrados = recentes
          .where(
            (item) =>
                item["mensagem"].toLowerCase().contains(texto.toLowerCase()),
          )
          .toList();
    });
  }

  void toggleTheme() {
    setState(() {
      isDark = !isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 🔹 CONTEÚDO
          Expanded(
            child: Container(
              color: isDark
                  ? const Color.fromARGB(255, 82, 15, 15)
                  : const Color(0xFFDCEFE8),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // 🔍 TOPO
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Text("P"),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            onChanged: buscar,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            decoration: InputDecoration(
                              hintText: "Buscar mensagens...",
                              hintStyle: TextStyle(
                                color: isDark ? Colors.white70 : Colors.grey,
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? const Color.fromARGB(255, 60, 10, 10)
                                  : Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: const Icon(Icons.search),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // 🌙 BOTÃO TEMA
                        IconButton(
                          onPressed: toggleTheme,
                          icon: Icon(
                            isDark ? Icons.light_mode : Icons.dark_mode,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 📋 LISTA
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: filtrados.length,
                      itemBuilder: (context, index) {
                        var item = filtrados[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatPage(
                                  grupoNome: item["grupo"],
                                  mensagens: grupos
                                      .firstWhere(
                                        (g) => g.nome == item["grupo"],
                                      )
                                      .mensagens,
                                  isDark: isDark,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color.fromARGB(255, 60, 10, 10)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.green,
                                  child: Text(
                                    item["grupo"],
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    item["mensagem"],
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 🔹 SIDEBAR (GRUPOS)
          Container(
            width: 60,
            color: isDark ? Colors.black : const Color(0xFF0F766E),
            child: Column(
              children: [
                const SizedBox(height: 100),
                for (var grupo in grupos)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatPage(
                            grupoNome: grupo.nome,
                            mensagens: grupo.mensagens,
                            isDark: isDark,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: grupo.nome == "G1"
                            ? Colors.red
                            : Colors.green,
                        child: Text(
                          grupo.nome,
                          style: const TextStyle(fontSize: 8),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatPage extends StatelessWidget {
  final String grupoNome;
  final List<String> mensagens;
  final bool isDark;

  const ChatPage({
    super.key,
    required this.grupoNome,
    required this.mensagens,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(grupoNome),
        backgroundColor: isDark ? Colors.red : const Color(0xFF1ABC9C),
      ),
      body: Container(
        color: isDark
            ? const Color.fromARGB(255, 82, 15, 15)
            : const Color(0xFFDCEFE8),
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: mensagens.length,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color.fromARGB(255, 60, 10, 10)
                    : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                mensagens[index],
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
            );
          },
        ),
      ),
    );
  }
}
