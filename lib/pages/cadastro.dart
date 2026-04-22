import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/theme_controller.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final nomeController = TextEditingController();
  final exibicaoController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final confirmController = TextEditingController();
  bool loading = false;

  // Cores Identidade
  final Color figmaVinhoEscuro = const Color(0xFF1D0000);
  final Color botaoVermelho = const Color(0xFFDA2B2B);

  Future<void> cadastrar() async {
    if (senhaController.text != confirmController.text) {
      _mostrarErro("As senhas não coincidem!");
      return;
    }
    setState(() => loading = true);
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: senhaController.text.trim(),
      );

      await FirebaseFirestore.instance.collection('usuarios').doc(userCredential.user!.uid).set({
        'nome': nomeController.text.trim(),
        'nome_exibicao': exibicaoController.text.trim(),
        'email': emailController.text.trim(),
        'bio': 'Estudante do Studdy-Buddy 🚀',
        'pontos_total': 0,
        'medalhas': [],
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Conta criada com sucesso!")));
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      _mostrarErro(e.message ?? "Erro ao cadastrar");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _mostrarErro(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = ThemeController.isDark;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Fundo
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark 
                    ? [const Color(0xFF350000), figmaVinhoEscuro] 
                    : [const Color(0xFFA8D7D6), const Color(0xFF8ED39A)],
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
              ),
            ),
          ),
          // 2. Balões
          Positioned.fill(
            child: Opacity(
              opacity: isDark ? 0.3 : 0.1,
              child: Image.asset(isDark ? 'assets/baloesvermelho.png' : 'assets/baloes.png', fit: BoxFit.cover),
            ),
          ),
          // 3. Botão Voltar
          Positioned(
            top: 40,
            left: 15,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // 4. Conteúdo Central
          Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // --- LOGO ADICIONADA AQUI ---
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      border: Border.all(color: isDark ? botaoVermelho : const Color(0xFF1ABC9C), width: 3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(isDark ? 'assets/logo.png' : 'assets/logobranca.png', width: 80),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("Crie sua conta", 
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  // Cartão
                  Container(
                    width: 340,
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: isDark ? figmaVinhoEscuro.withOpacity(0.9) : Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
                    ),
                    child: Column(
                      children: [
                        _field(isDark, "Nome Completo", nomeController, Icons.person_outline),
                        _field(isDark, "Nome de Exibição", exibicaoController, Icons.badge_outlined),
                        _field(isDark, "E-mail", emailController, Icons.email_outlined),
                        _field(isDark, "Senha", senhaController, Icons.lock_outline, isPass: true),
                        _field(isDark, "Confirmar Senha", confirmController, Icons.lock_reset_outlined, isPass: true),
                        const SizedBox(height: 10),
                        // Botão com texto alterado para REALIZAR CADASTRO
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: loading ? null : cadastrar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? botaoVermelho : const Color(0xFF4CAF50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              elevation: 0,
                            ),
                            child: loading 
                                ? const CircularProgressIndicator(color: Colors.white) 
                                : const Text("REALIZAR CADASTRO", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    );
  }

  Widget _field(bool isDark, String label, TextEditingController ctrl, IconData icon, {bool isPass = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: ctrl,
        obscureText: isPass,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 14),
          prefixIcon: Icon(icon, color: isDark ? Colors.white38 : Colors.black38),
          filled: true,
          fillColor: isDark ? const Color(0xFF2D0505) : Colors.grey[200],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}