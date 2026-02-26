import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Lista de libros "ficticia" para que tus amigos vean cómo se vería
    final List<Map<String, String>> libros = [
      {'titulo': 'Cálculo de Stewart', 'precio': '20\$', 'estado': 'Nuevo'},
      {'titulo': 'Física Universitaria', 'precio': '15\$', 'estado': 'Usado'},
      {'titulo': 'Derecho Romano', 'precio': '10\$', 'estado': 'Como nuevo'},
      {'titulo': 'Economía Samuelson', 'precio': '25\$', 'estado': 'Nuevo'},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Marketplace Unimet', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text('Libros Disponibles', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Dos columnas de libros
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.8,
              ),
              itemCount: libros.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.book, size: 50, color: Color(0xFF1976D2)),
                      const SizedBox(height: 10),
                      Text(libros[index]['titulo']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(libros[index]['precio']!, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      Text(libros[index]['estado']!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aquí tus amigos programarán el formulario para subir libros
        },
        backgroundColor: const Color(0xFF1976D2),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Responsive simple para Web: 2 columnas en pantallas pequeñas, 3 o 4 en grandes
  int _columnsForWidth(double width) {
    if (width >= 1100) return 4;
    if (width >= 800) return 3;
    return 2;
  }
}

class _LibroCard extends StatelessWidget {
  final String titulo;
  final String precio;
  final String estado;

  const _LibroCard({
    required this.titulo,
    required this.precio,
    required this.estado,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            blurRadius: 6,
            color: Colors.black12,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.book,
              size: 50,
              color: Color(0xFF1976D2),
            ),
            const SizedBox(height: 10),
            Text(
              titulo,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              precio,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              estado,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}