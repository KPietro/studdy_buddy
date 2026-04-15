import 'package:flutter/material.dart';

// O "../" significa "volte uma pasta", saia de 'pages' e entre em 'controllers'
import '../controllers/theme_controller.dart';

// Como o home.dart está na mesma pasta, é só chamar direto:
import 'home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoading = true;
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

  Future<void> login(String email, String senha) async {
    await Future.delayed(const Duration(seconds: 2));

    if (email == "admin@gmail.com" && senha == "123") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login realizado com sucesso!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email ou senha incorretos")),
      );
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
              child: AnimatedScale(
                duration: const Duration(milliseconds: 400),
                scale: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                          isDark ? 'assets/logo.png' : 'assets/logobranca.png',
                          width: 100,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
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
                            "Senha:",
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
                              hintText: "ExemploSenha123",
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
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomePage(
                                      isDark: ThemeController.isDark,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark
                                    ? const Color.fromARGB(255, 218, 43, 43)
                                    : const Color(0xFF4CAF50),
                              ),
                              child: const Text("Entrar"),
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
