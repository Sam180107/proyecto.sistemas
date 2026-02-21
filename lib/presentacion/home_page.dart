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
      {'titulo': 'Álgebra Lineal', 'precio': '18\$', 'estado': 'Usado'},
      {'titulo': 'Termodinámica', 'precio': '30\$', 'estado': 'Nuevo'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7), // Gris claro de fondo
      appBar: AppBar(
        title: const Text(
          'BookSwap', 
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
        ),
        centerTitle: true, // Nombre centrado para que se vea más moderno
        backgroundColor: const Color(0xFF003870), // Azul Unimet
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              // Al cerrar sesión, volvemos a la pantalla de login
              Navigator.pushReplacementNamed(context, '/');
            },
            tooltip: 'Cerrar Sesión',
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
            child: Text(
              'Libros Disponibles', 
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF333333))
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Dos columnas de libros
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.85,
              ),
              itemCount: libros.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.menu_book_rounded, size: 60, color: Color(0xFF003870)),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          libros[index]['titulo']!, 
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        libros[index]['precio']!, 
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          libros[index]['estado']!, 
                          style: const TextStyle(color: Colors.grey, fontSize: 11)
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Aquí se abrirá el formulario para subir libros
          print("Abrir formulario de subida");
        },
        label: const Text('Vender Libro', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color(0xFFFF6B00), // Naranja Unimet para que resalte
      ),
    );
  }
}