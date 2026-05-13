import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/theme_controller.dart';
import 'login.dart';
import 'home.dart';

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  @override
  Widget build(BuildContext context) {
    // O StreamBuilder fica "ouvindo" o Firebase Auth continuamente
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Enquanto o Firebase procura o token no celular, mostra a bolinha carregando
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF1D0000), // Usando a cor do seu design
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFDA2B2B)),
            ),
          );
        }

        // Se encontrou um usuário logado no celular, vai direto pra Home!
        if (snapshot.hasData && snapshot.data != null) {
          return HomePage(isDark: ThemeController.isDark);
        }

        // Se não encontrou ninguém logado (ou se o usuário clicou em Sair depois), vai pro Login
        return const LoginPage();
      },
    );
  }
}
