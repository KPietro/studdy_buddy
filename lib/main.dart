import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Necessário para o kReleaseMode
import 'package:device_preview/device_preview.dart'; // O pacote mágico

import 'ranking_semanal.dart'; // O arquivo que criamos na resposta anterior

void main() {
  runApp(
    DevicePreview(
      // O device preview só vai aparecer enquanto você estiver desenvolvendo (debug).
      // Quando gerar o app final pro usuário, ele some automaticamente.
      enabled: !kReleaseMode,
      builder: (context) => const MeuProjetoApp(),
    ),
  );
}

class MeuProjetoApp extends StatelessWidget {
  const MeuProjetoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Estas 3 linhas abaixo são obrigatórias para o DevicePreview funcionar
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,

      debugShowCheckedModeBanner: false,
      title: 'Projeto Senac',
      home: const RankingSemanal(),
    );
  }
}
