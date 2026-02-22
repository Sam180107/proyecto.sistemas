import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        toolbarHeight: 70,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: AssetImage('assets/sdi.assets.jpg'), // Asegúrate de que el logo esté en esta ruta
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "BookSwap",
              style: TextStyle(color: Color(0xFF003870), fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              "Sistema de Intercambio Académico",
              style: TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ],
        ),
        actions: [
          _navItem(context, Icons.home, "Inicio", true, () {
            // Ya estamos aquí
          }),
          _navItem(context, Icons.search, "Buscar", false, () {
            // Lógica de búsqueda
          }),
          _navItem(context, Icons.add_circle_outline, "Publicar", false, () {
            // Lógica para subir libro
          }),
          // BOTÓN DE PERFIL: Ahora sí ejecuta la navegación
          _navItem(context, Icons.person_outline, "Perfil", false, () {
            Navigator.pushNamed(context, '/perfil');
          }),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Explorar Material Académico",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Encuentra libros y material de estudio para tus cursos",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            
            // Buscador y Filtro (Estilo Figma)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Buscar libros, materias, autores...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.tune, color: Color(0xFF003870)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // Grid de Libros
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemCount: 4, // Esto luego lo cambiaremos por datos reales de Firebase
              itemBuilder: (context, index) => _buildBookCard(),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para los botones de la barra superior
  Widget _navItem(BuildContext context, IconData icon, String label, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: active ? const Color(0xFF003870) : Colors.black87,
              size: 24,
            ),
            Text(
              label,
              style: TextStyle(
                color: active ? const Color(0xFF003870) : Colors.black87,
                fontSize: 10,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget de las tarjetas de libros
  Widget _buildBookCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Container(
                  height: 140,
                  color: Colors.grey[200],
                  child: const Center(child: Icon(Icons.book, size: 40, color: Colors.grey)),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF003870),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    "Venta",
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "MATEMÁTICAS",
                  style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  "Cálculo: Una Variable",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "James Stewart",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                SizedBox(height: 8),
                Text(
                  "\$ 45.00",
                  style: TextStyle(color: Color(0xFF003870), fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}