import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/theme_controller.dart';
import 'home.dart';
import 'cadastro.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoadingTheme = true;
  bool isLoggingIn = false; // Para o loading do botão

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
      isLoadingTheme = false;
    });
  }

  void toggleTheme() async {
    ThemeController.isDark = !ThemeController.isDark;
    await ThemeController.saveTheme(ThemeController.isDark);
    setState(() {});
  }

  // Lógica de Login integrada
  Future<void> login() async {
    if (emailController.text.isEmpty || senhaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha todos os campos!")),
      );
      return;
    }

    setState(() => isLoggingIn = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: senhaController.text.trim(),
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(isDark: ThemeController.isDark),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String erro = "Erro ao entrar.";
      if (e.code == 'invalid-credential') erro = "E-mail ou senha incorretos.";
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(erro)));
    } finally {
      if (mounted) setState(() => isLoggingIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingTheme)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    bool isDark = ThemeController.isDark;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: Stack(
          key: ValueKey(isDark),
          children: [
            // SEU GRADIENTE ORIGINAL
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
            // SEUS BALÕES ORIGINAIS
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
            // SEU BOTÃO DE TEMA ORIGINAL
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
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // LOGO
                    Container(
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
                          isDark ? 'assets/logo.png' : 'assets/logobranca.png',
                          width: 100,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // FORMULÁRIO ORIGINAL
                    Container(
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
                          TextField(
                            controller: emailController,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            decoration: InputDecoration(
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
                            "Senha:",
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextField(
                            controller: senhaController,
                            obscureText: true,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            decoration: InputDecoration(
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
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLoggingIn ? null : login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark
                                    ? const Color.fromARGB(255, 218, 43, 43)
                                    : const Color(0xFF4CAF50),
                              ),
                              child: isLoggingIn
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      "Entrar",
                                      style: TextStyle(color: Colors.white),
                                    ),
                            ),
                          ),
                          Center(
                            child: TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CadastroPage(),
                                ),
                              ),
                              child: Text(
                                "Criar conta",
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black87,
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
          ],
        ),
      ),
    );
  }
}
