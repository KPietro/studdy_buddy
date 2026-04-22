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
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  bool isLoggingIn = false;

  Future<void> login() async {
    if (emailController.text.isEmpty || senhaController.text.isEmpty) return;

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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro)));
    } finally {
      if (mounted) setState(() => isLoggingIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = ThemeController.isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF160303) : Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Image.asset(
                isDark ? 'assets/logo.png' : 'assets/logobranca.png',
                width: 120,
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2D0505)
                      : const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: "E-mail"),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: senhaController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: "Senha"),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoggingIn ? null : login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: isLoggingIn
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text("Entrar"),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CadastroPage(),
                    ),
                  );
                },
                child: const Text(
                  "Criar uma conta nova",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
