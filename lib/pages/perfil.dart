import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  // Controladores de texto
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  
  // Instâncias do Firebase
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Estados da tela
  bool _isEditing = false;
  bool _isUploading = false;

  // Cores de Identidade Visual
  final Color figmaVinhoEscuro = const Color(0xFF1D0000);
  final Color figmaInputFill = const Color(0xFF2D0505);
  final Color botaoVermelho = const Color(0xFFDA2B2B);

  // --- FUNÇÃO PARA PEGAR FOTO DA GALERIA E ENVIAR AO FIREBASE ---
  Future<void> _fazerUploadFoto(String campo) async {
    if (!_isEditing) return; // Só funciona se o modo de edição estiver ativo

    final ImagePicker picker = ImagePicker();
    // Abre a galeria do celular
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Comprime a imagem para economizar espaço
    );

    if (image != null) {
      setState(() => _isUploading = true);
      try {
        // 1. Referência do local onde o arquivo será salvo no Storage
        // Exemplo de caminho: usuarios/ID_DO_USER/url_perfil.jpg
        Reference ref = _storage
            .ref()
            .child('usuarios')
            .child(user!.uid)
            .child('$campo.jpg');

        // 2. Upload do arquivo
        UploadTask task = ref.putFile(File(image.path));
        TaskSnapshot snapshot = await task;

        // 3. Pegar a URL pública gerada pelo Firebase
        String urlGerada = await snapshot.ref.getDownloadURL();

        // 4. Salvar essa URL no Firestore dentro do documento do usuário
        await _firestore.collection('usuarios').doc(user!.uid).update({
          campo: urlGerada,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Imagem atualizada com sucesso!")),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erro ao enviar imagem: $e")),
          );
        }
      } finally {
        setState(() => _isUploading = false);
      }
    }
  }

  // --- FUNÇÃO PARA SALVAR TEXTOS (NOME E BIO) ---
  Future<void> _salvarPerfil() async {
    try {
      await _firestore.collection('usuarios').doc(user!.uid).update({
        'nome_exibicao': _nomeController.text.trim(),
        'bio': _bioController.text.trim(),
      });
      setState(() => _isEditing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Perfil salvo!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao salvar: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Usuário não logado")));
    }

    return Scaffold(
      backgroundColor: figmaVinhoEscuro,
      // Botão de Edição (Engrenagem / Check)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_isEditing) {
            _salvarPerfil();
          } else {
            setState(() => _isEditing = true);
          }
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Icon(
          _isEditing ? Icons.check_circle : Icons.settings,
          color: botaoVermelho,
          size: 45,
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('usuarios').doc(user!.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.red));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text("Dados não encontrados", style: TextStyle(color: Colors.white)),
            );
          }

          var dados = snapshot.data!.data() as Map<String, dynamic>;
          
          // Sincroniza controllers com o banco apenas quando NÃO está editando
          if (!_isEditing) {
            _nomeController.text = dados['nome_exibicao'] ?? dados['nome'] ?? "Usuário";
            _bioController.text = dados['bio'] ?? "";
          }

          // Imagens (Usa links do banco ou placeholders se estiverem vazios)
          String urlCapa = dados['url_capa'] ?? "https://via.placeholder.com/800x400/2D0505/FFFFFF?text=Capa";
          String urlPerfil = dados['url_perfil'] ?? "https://www.w3schools.com/howto/img_avatar.png";

          return SingleChildScrollView(
            child: Column(
              children: [
                // 1. ÁREA DAS FOTOS (CAPA E PERFIL)
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Foto de Capa (Fundo)
                    GestureDetector(
                      onTap: () => _fazerUploadFoto('url_capa'),
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(urlCapa),
                            fit: BoxFit.cover,
                            colorFilter: _isEditing 
                                ? ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken) 
                                : null,
                          ),
                        ),
                        child: _isEditing 
                            ? const Icon(Icons.camera_alt, color: Colors.white, size: 40) 
                            : null,
                      ),
                    ),
                    // Botão Voltar
                    Positioned(
                      top: 40,
                      left: 15,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    // Foto de Perfil (Avatar)
                    Positioned(
                      bottom: -50,
                      left: 20,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () => _fazerUploadFoto('url_perfil'),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 110,
                                  height: 110,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 3),
                                    image: DecorationImage(
                                      image: NetworkImage(urlPerfil),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                if (_isEditing)
                                  Container(
                                    width: 110,
                                    height: 110,
                                    decoration: const BoxDecoration(
                                      color: Colors.black38,
                                      shape: BoxShape.circle,
                                    ),
                                    child: _isUploading 
                                        ? const Padding(
                                            padding: EdgeInsets.all(35.0),
                                            child: CircularProgressIndicator(color: Colors.white),
                                          )
                                        : const Icon(Icons.edit, color: Colors.white, size: 30),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 15),
                          // Nome e Email
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _isEditing 
                                ? SizedBox(
                                    width: 180,
                                    child: TextField(
                                      controller: _nomeController,
                                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                                      ),
                                    ),
                                  )
                                : Text(
                                    _nomeController.text,
                                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                                  ),
                              Text(dados['email'] ?? "", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 70),

                // 2. BIO
                _buildSectionTitle("Sobre mim (Bio)"),
                _buildContainerBox(
                  height: 110,
                  child: TextField(
                    controller: _bioController,
                    enabled: _isEditing,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: "Fale um pouco sobre você...",
                      hintStyle: TextStyle(color: Colors.white30),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                // 3. ATIVIDADE (GRÁFICOS VISUAIS)
                _buildSectionTitle("Progresso Semanal"),
                _buildContainerBox(
                  height: 150,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: _generateMockBars(),
                  ),
                ),

                const SizedBox(height: 20),

                // 4. CONQUISTAS / PONTOS
                _buildSectionTitle("Conquistas"),
                _buildContainerBox(
                  height: 85,
                  child: Row(
                    children: [
                      const Icon(Icons.stars, color: Colors.amber, size: 45),
                      const SizedBox(width: 15),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${dados['pontos_total'] ?? 0} Pontos",
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Text("Nível: Estudante Prata", style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 60),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildContainerBox({required double height, required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(15),
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: figmaInputFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10, width: 1),
      ),
      child: child,
    );
  }

  List<Widget> _generateMockBars() {
    // Gera 10 barrinhas de alturas variadas para o gráfico
    return List.generate(10, (index) {
      return Container(
        width: 18,
        height: (index % 4 + 2) * 15.0,
        decoration: BoxDecoration(
          color: botaoVermelho.withOpacity(0.8),
          borderRadius: BorderRadius.circular(6),
        ),
      );
    });
  }
}