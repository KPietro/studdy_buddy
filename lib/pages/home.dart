import 'package:flutter/material.dart';
import '../controllers/theme_controller.dart';
import 'criacao_grupo.dart';
import 'chats_recentes.dart';
import 'registro_atividade.dart';
import 'grupo_page.dart'; // Vamos criar esse arquivo no próximo passo!
import 'perfil.dart';

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

  void toggleTheme() async {
    ThemeController.isDark = !ThemeController.isDark;
    await ThemeController.saveTheme(ThemeController.isDark);
    setState(() {
      isDark = ThemeController.isDark;
    });
  }

  // Cores baseadas no seu Figma
  Color get bgMain =>
      isDark ? const Color(0xFF160303) : const Color(0xFFEAFaf1);
  Color get bgSidebar =>
      isDark ? const Color(0xFF4A0000) : const Color(0xFF4CAF50);
  Color get textMain => isDark ? Colors.white : Colors.black;
  Color get pillBg =>
      isDark ? const Color(0xFF333333) : const Color(0xFFB0B0B0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgMain,
      body: SafeArea(
        child: Row(
          children: [
            // 🔹 CONTEÚDO PRINCIPAL (ESQUERDA)
            Expanded(
              child: Stack(
                children: [
                  Column(
                    children: [
                      // 🔍 TOPO (Avatar + Search)
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
    const SizedBox(height: 50),
    
    // --- ÍCONE DE PERFIL COM NAVEGAÇÃO ---
    GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PerfilPage()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 2),
        ),
        child: CircleAvatar(
          radius: 25,
          backgroundColor: isDark ? Colors.white10 : Colors.black12,
          child: Icon(
            Icons.person, 
            color: textMain, // Usa a cor definida no seu getter
            size: 30,
          ),
        ),
      ),
    ),

    const SizedBox(height: 20),
    const Divider(color: Colors.white24, indent: 15, endIndent: 15),
    
    // ... restante da sua lista de grupos (ListView.builder)
  ],
                        ),
                      ),

                      // Título "Recentes"
                      Text(
                        "Recentes",
                        style: TextStyle(
                          color: textMain,
                          fontSize: 28,
                          fontFamily:
                              'Comic Sans MS', // Substitua pela fonte exata do Figma depois
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 📋 LISTA DE RECENTES
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(
                            left: 30,
                            right: 20,
                            bottom: 80,
                          ),
                          itemCount: 10, // Quantidade mockada
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  // Pílula Cinza
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.only(
                                      left: 40,
                                      top: 8,
                                      bottom: 8,
                                      right: 15,
                                    ),
                                    decoration: BoxDecoration(
                                      color: pillBg,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: const Text(
                                      "Ablublé tanana bla bla\nbla...",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  // Avatar sobreposto (vazando para a esquerda)
                                  Positioned(
                                    left: -15,
                                    top: 2,
                                    child: Stack(
                                      children: [
                                        const CircleAvatar(
                                          radius: 18,
                                          backgroundColor: Colors.green,
                                          child: Text(
                                            "P",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 0,
                                          top: 0,
                                          child: CircleAvatar(
                                            radius: 6,
                                            backgroundColor: Colors.red,
                                            child: Text(
                                              "G1",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 5,
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
                          },
                        ),
                      ),
                    ],
                  ),

                  // ⚙️ ENGRENAGEM E TEMA (Canto Inferior Esquerdo)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: GestureDetector(
                      onTap:
                          toggleTheme, // Usando a engrenagem para trocar o tema por enquanto!
                      child: Icon(
                        Icons.settings,
                        color: isDark ? Colors.red : Colors.greenAccent,
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 SIDEBAR (DIREITA)
            Container(
              width: 70,
              decoration: BoxDecoration(
                color: bgSidebar,
                border: Border(
                  left: BorderSide(
                    color: isDark ? Colors.red.shade900 : Colors.green.shade800,
                    width: 2,
                  ),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Botão de Mais
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CriacaoGrupoPage(isDark: isDark),
                        ),
                      );
                    },
                    child: Icon(
                      Icons.add_circle_outline,
                      color: textMain,
                      size: 45,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Divider(color: Colors.white54, thickness: 1),
                  ),
                  const SizedBox(height: 10),

                  // Lista de Grupos
                  Expanded(
                    child: ListView.builder(
                      itemCount: 8,
                      itemBuilder: (context, index) {
                        bool isG1 = index % 2 == 0;
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GrupoPage(
                                  isDark: isDark,
                                  grupoNome: isG1 ? "G1" : "G2",
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: isG1
                                  ? Colors.red
                                  : Colors.greenAccent,
                              child: Text(
                                isG1 ? "G1" : "G2",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Ícone de Mensagem no final
                  // Ícone de Mensagem no final da barra lateral
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ChatsRecentesPage(isDark: isDark)));
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Icon(
                        Icons.email_outlined,
                        color: textMain,
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
