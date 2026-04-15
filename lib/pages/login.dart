import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import do Firebase Auth

import '../controllers/theme_controller.dart';
import 'home.dart';
import 'cadastro.dart'; // Import da tela de cadastro, se o usuário não tiver conta

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoading = true;
  bool isLoggingIn = false; // Controle da animação de loading no botão

  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadTheme();
  }

  void loadTheme() async {
    await ThemeController.loadTheme();
    setState(() {
      isLoading = false;
    });
  }

  void toggleTheme() async {
    ThemeController.isDark = !ThemeController.isDark;
    await ThemeController.saveTheme(ThemeController.isDark);
    setState(() {});
  }

  // 🔥 FUNÇÃO DE LOGIN REAL COM FIREBASE
  Future<void> fazerLogin() async {
    // 1. Verifica se os campos não estão vazios
    if (emailController.text.isEmpty || senhaController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Preencha todos os campos")));
      return;
    }

    // 2. Inicia o loading no botão
    setState(() => isLoggingIn = true);

    try {
      // 3. Tenta fazer login no Firebase Auth
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(), // Remove espaços em branco
        password: senhaController.text.trim(),
      );

      // 4. Se passou sem erro, vai para a Home!
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(isDark: ThemeController.isDark),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      // 5. Trata os erros comuns (e-mail errado, senha errada, etc.)
      String mensagemErro = "Erro ao fazer login. Tente novamente.";

      if (e.code == 'user-not-found' || e.code == 'invalid-email') {
        mensagemErro = 'Nenhum usuário encontrado com este e-mail.';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        mensagemErro = 'E-mail ou senha incorretos.';
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensagemErro)));
      }
    } finally {
      // 6. Para o loading de qualquer jeito (dando certo ou erro)
      if (mounted) {
        setState(() => isLoggingIn = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    bool isDark = ThemeController.isDark;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: Stack(
          key: ValueKey(isDark),
          children: [
            // 🔥 FUNDO DEGRADÊ
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          const Color.fromARGB(255, 233, 86, 86),
                          const Color.fromARGB(255, 83, 21, 16),
                        ]
                      : [const Color(0xFFA8D7D6), const Color(0xFF8ED39A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // 🔥 IMAGEM DE FUNDO (BALÕES)
            Positioned.fill(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: isDark ? 1 : 0.15,
                child: Image.asset(
                  isDark ? 'assets/baloesvermelho.png' : 'assets/baloes.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // 🔥 BOTÃO TEMA
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                onPressed: toggleTheme,
                icon: Icon(
                  isDark ? Icons.light_mode : Icons.dark_mode,
                  color: Colors.white,
                ),
              ),
            ),

            // 🔹 CONTEÚDO CENTRAL
            Center(
              child: SingleChildScrollView(
                // Para não quebrar a tela se o teclado abrir
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 400),
                  scale: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 🔹 LOGO
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDark
                                ? Colors.black
                                : const Color(0xFF1ABC9C),
                            width: 4,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            isDark
                                ? 'assets/logo.png'
                                : 'assets/logobranca.png',
                            width: 100,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 🔹 CARD DE LOGIN
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        width: 320,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color.fromARGB(255, 82, 15, 15)
                              : const Color(0xFF9FB8A3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "E-mail:",
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            TextField(
                              controller: emailController,
                              keyboardType: TextInputType
                                  .emailAddress, // Ajuda no teclado do celular
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              decoration: InputDecoration(
                                hintText: "Exemplo@gmail.com",
                                hintStyle: TextStyle(
                                  color: isDark ? Colors.white70 : Colors.grey,
                                ),
                                filled: true,
                                fillColor: isDark
                                    ? const Color.fromARGB(255, 60, 10, 10)
                                    : Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              "senha:",
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            TextField(
                              controller: senhaController,
                              obscureText: true,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              decoration: InputDecoration(
                                hintText: "ExemplosSenha123",
                                hintStyle: TextStyle(
                                  color: isDark ? Colors.white70 : Colors.grey,
                                ),
                                filled: true,
                                fillColor: isDark
                                    ? const Color.fromARGB(255, 60, 10, 10)
                                    : Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // 🔹 BOTÃO ENTRAR
                            SizedBox(
                              width: double.infinity,
                              height: 45,
                              child: ElevatedButton(
                                onPressed: isLoggingIn
                                    ? null
                                    : fazerLogin, // Trava o botão durante o login
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark
                                      ? const Color.fromARGB(255, 218, 43, 43)
                                      : const Color(0xFF4CAF50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(
                                      color: isDark
                                          ? Colors.black
                                          : Colors.black45,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: isLoggingIn
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        "Entrar",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 15),

                            // 🔹 LINK PARA CADASTRO
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  // Navega para a página de Cadastro
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CadastroPage(),
                                    ),
                                  );
                                },
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 12,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text: "Não possui uma conta? ",
                                      ),
                                      TextSpan(
                                        text: "Cadastrar",
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.red
                                              : Colors.green[800],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
