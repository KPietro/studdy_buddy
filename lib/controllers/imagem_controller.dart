import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ImagemController {
  // Coloque seus dados do Cloudinary aqui!
  static const String cloudName = "dijjssfgi";
  static const String uploadPreset = "studdy_buddy_preset";

  static Future<String?> escolherESubirImagem() async {
    // 1. Abre a galeria
    final picker = ImagePicker();
    final XFile? foto = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Comprime a imagem
    );

    if (foto == null) return null; // Usuário cancelou

    File arquivoImagem = File(foto.path);

    try {
      // 2. Prepara a requisição para o Cloudinary
      var uri = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
      );
      var request = http.MultipartRequest("POST", uri);

      request.fields['upload_preset'] = uploadPreset;
      request.files.add(
        await http.MultipartFile.fromPath('file', arquivoImagem.path),
      );

      // 3. Envia e espera a resposta
      var response = await request.send();

      if (response.statusCode == 200) {
        // 4. Deu certo! Pega o link da imagem
        var responseData = await response.stream.bytesToString();
        var jsonMap = json.decode(responseData);
        String linkDaImagem = jsonMap['secure_url'];

        return linkDaImagem;
      } else {
        print("Erro do Cloudinary: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Erro ao subir imagem: $e");
      return null;
    }
  }
}
