import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';

// 1. Modelo de datos (Data)
// Esta lista centraliza la información para que sea fácil de mantener o conectar a Firebase luego.
final List<Map<String, String>> libros = [
  {
    'titulo': 'Cálculo: Una Variable',
    'autor': 'James Stewart',
    'precio': '45.00',
    'categoria': 'MATEMÁTICAS',
    'imagen': 'assets/calculo.jpg',
    'vendedor': 'María González',
    'carrera': 'Ingeniería Civil',
    'iniciales': 'MG',
    'descripcion': 'Libro en excelente estado, edición 8va. Incluye todos los capítulos sin marcas ni subrayados. Perfecto para cursos de Cálculo I y II.',
  },
  {
    'titulo': 'Física Universitaria',
    'autor': 'Sears & Zemansky',
    'precio': '50.00',
    'categoria': 'FÍSICA',
    'imagen': 'assets/fisica.jpg',
    'vendedor': 'Ricardo Pérez',
    'carrera': 'Ingeniería de Sistemas',
    'iniciales': 'RP',
    'descripcion': 'Casi nuevo, incluye el solucionario impreso. Muy útil para los laboratorios de Física I.',
  },
  // Puedes añadir más mapas aquí y el Grid se actualizará solo
];

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F6), // Fondo gris claro moderno
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Libros Disponibles",
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF003870),
                ),
              ),
              const SizedBox(height: 20),
              
              // 2. Grid de Libros
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), // El scroll lo maneja el SingleChildScrollView
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,       // 2 columnas para móvil
                  crossAxisSpacing: 14,    // Espacio horizontal
                  mainAxisSpacing: 14,     // Espacio vertical
                  childAspectRatio: 0.65,  // Relación ancho/alto para que no se corte el texto
                ),
                itemCount: libros.length,
                itemBuilder: (context, index) {
                  return _buildBookCard(context, libros[index]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 3. Constructor de la Tarjeta de Libro
  Widget _buildBookCard(BuildContext context, Map<String, String> libro) {
    return GestureDetector(
      onTap: () {
        // Navegación enviando el mapa completo del libro seleccionado
        Navigator.pushNamed(
          context, 
          '/detalle_libro', 
          arguments: libro
        );
      },
      child: Container(
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
            // Sección Superior: Imagen y Etiqueta
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.book, size: 40, color: Colors.grey),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E88E5), // Azul vibrante para "Venta"
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text(
                      "VENTA",
                      style: TextStyle(
                        color: Colors.white, 
                        fontSize: 9, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Sección Inferior: Detalles del Libro
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    libro['categoria']!.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.grey, 
                      fontSize: 9, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    libro['titulo']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 13,
                      height: 1.2
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    libro['autor']!,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "\$ ${libro['precio']}",
                    style: const TextStyle(
                      color: Color(0xFF1E88E5),
                      fontWeight: FontWeight.bold, 
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}