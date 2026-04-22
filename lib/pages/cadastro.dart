import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  // Controladores para capturar o texto dos campos
  final nomeController = TextEditingController();
  final exibicaoController = TextEditingController(); // Novo campo
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final confirmController = TextEditingController();

  bool loading = false;

  Future<void> cadastrar() async {
    // Validações Básicas
    if (senhaController.text != confirmController.text) {
      _mostrarErro("As senhas não coincidem!");
      return;
    }

    if (nomeController.text.isEmpty ||
        exibicaoController.text.isEmpty ||
        emailController.text.isEmpty) {
      _mostrarErro("Por favor, preencha todos os campos obrigatórios!");
      return;
    }

    setState(() => loading = true);

    try {
      // 1. Criar o utilizador no Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: senhaController.text.trim(),
          );

      String uid = userCredential.user!.uid;

      // 2. Atualizar o DisplayName nativo do Firebase Auth
      await userCredential.user!.updateDisplayName(
        exibicaoController.text.trim(),
      );

      // 3. Criar o documento no Firestore (Coleção: usuarios | ID: uid)
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
        'nome': nomeController.text.trim(),
        'nome_exibicao': exibicaoController.text.trim(),
        'email': emailController.text.trim(),
        'bio': 'Estudante do Studdy-Buddy 🚀',
        'foto_url': '',
        'pontos_total': 0,
        'pontos_semanal': 0,
        'medalhas': [],
        'grupos_vinculados': [],
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Conta criada com sucesso!")),
        );
        Navigator.pop(context); // Volta para a tela de Login
      }
    } on FirebaseAuthException catch (e) {
      String msg = "Ocorreu um erro no cadastro.";
      if (e.code == 'weak-password') msg = "A senha é demasiado fraca.";
      if (e.code == 'email-already-in-use') msg = "Este e-mail já está em uso.";
      _mostrarErro(msg);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Container(
            width: 380,
            decoration: BoxDecoration(
              color: const Color(0xFF121212),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                const Icon(Icons.person_add, size: 60, color: Colors.red),
                const SizedBox(height: 20),
                _field("Nome Completo", nomeController),
                _field(
                  "Nome de Exibição (Como aparecerás no Ranking)",
                  exibicaoController,
                ),
                _field("E-mail", emailController),
                _field("Senha", senhaController, isPass: true),
                _field("Confirmar Senha", confirmController, isPass: true),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: loading ? null : cadastrar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Finalizar Registo"),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Voltar ao Login",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    bool isPass = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: isPass,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white60, fontSize: 13),
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
