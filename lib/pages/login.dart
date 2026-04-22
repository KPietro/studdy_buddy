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

  // Cores ajustadas: Vermelho do seu código original
  final Color figmaVinhoEscuro = const Color(0xFF1D0000);
  final Color botaoVermelho = const Color(
    0xFFDA2B2B,
  ); // O vermelho que você enviou
  final Color figmaInputFill = const Color(0xFF2D0505);

  @override
  void initState() {
    super.initState();
    loadTheme();
  }

  void loadTheme() async {
    await ThemeController.loadTheme();
    setState(() => isLoadingTheme = false);
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
      String erro = "E-mail ou senha incorretos.";
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
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF350000), figmaVinhoEscuro]
                      : [const Color(0xFFA8D7D6), const Color(0xFF8ED39A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned.fill(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: isDark ? 0.4 : 0.15,
                child: Image.asset(
                  isDark ? 'assets/baloesvermelho.png' : 'assets/baloes.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
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
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDark
                              ? botaoVermelho
                              : const Color(0xFF1ABC9C),
                          width: 3,
                        ),
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          isDark ? 'assets/logo.png' : 'assets/logobranca.png',
                          width: 90,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    // Cartão
                    Container(
                      width: 330,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 35,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? figmaVinhoEscuro.withOpacity(0.9)
                            : Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Column(
                        children: [
                          _buildField(
                            isDark,
                            "E-mail",
                            emailController,
                            Icons.email_outlined,
                          ),
                          const SizedBox(height: 15),
                          _buildField(
                            isDark,
                            "Senha",
                            senhaController,
                            Icons.lock_outline,
                            isPass: true,
                          ),
                          const SizedBox(height: 20),
                          // Botão Principal Vermelho
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: isLoggingIn ? null : login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark
                                    ? botaoVermelho
                                    : const Color(0xFF4CAF50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 0,
                              ),
                              child: isLoggingIn
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      "ENTRAR",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CadastroPage(),
                              ),
                            ),
                            child: RichText(
                              text: TextSpan(
                                text: "Não possui uma conta? ",
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black87,
                                ),
                                children: [
                                  TextSpan(
                                    text: "Cadastrar",
                                    style: TextStyle(
                                      color: isDark
                                          ? botaoVermelho
                                          : Colors.green[800],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
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

  Widget _buildField(
    bool isDark,
    String hint,
    TextEditingController ctrl,
    IconData icon, {
    bool isPass = false,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: isPass,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
        prefixIcon: Icon(icon, color: isDark ? Colors.white38 : Colors.black38),
        filled: true,
        fillColor: isDark ? figmaInputFill : Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
