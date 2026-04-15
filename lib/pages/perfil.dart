import 'package:flutter/material.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final TextEditingController _bioController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D0000),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.settings, color: Color(0xFFE91E63), size: 40),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/sim.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const Positioned(
                  top: 40,
                  left: 15,
                  child: Icon(Icons.arrow_back, color: Colors.black, size: 35),
                ),
                Positioned(
                  bottom: -40,
                  left: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/perfil.jpg'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
            _buildSectionTitle("Insira sua bio aqui."),
            _buildContainerBox(
              height: 120,
              child: TextField(
                controller: _bioController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Digite algo...",
                  hintStyle: TextStyle(color: Colors.white24),
                ),
              ),
            ),
            _buildSectionTitle("Últimos 30 dias"),
            _buildContainerBox(
              height: 180,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _generateMockBars(),
              ),
            ),
            _buildSectionTitle("Seu grupo favorito"),
            _buildContainerBox(
              height: 100,
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.greenAccent,
                    child: Text(
                      "G2",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Tim",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        Text(
                          "4000 pontos",
                          style: TextStyle(color: Colors.green, fontSize: 12),
                        ),
                        Text(
                          "🏅 1 medalha",
                          style: TextStyle(color: Colors.amber, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Primeiro Sábio",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildContainerBox({required double height, required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(15),
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF2D0505),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: child,
    );
  }

  List<Widget> _generateMockBars() {
    return List.generate(20, (index) {
      double h = (index % 5 + 2) * 15.0;
      return Container(
        width: 8,
        height: h,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(2),
        ),
      );
    });
  }
}
