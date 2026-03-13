import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/custom_app_bar.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Debes iniciar sesión para ver tus favoritos')),
      );
    }

    return Scaffold(
        appBar: const CustomAppBar(),
        backgroundColor: const Color(0xFFF2F4F7),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mis Favoritos',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF003870),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('usuarios')
                      .doc(userId)
                      .collection('favoritos')
                      .orderBy('fecha_agregado', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Aún no tienes favoritos',
                              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      );
                    }

                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Ajustable según diseño responsive
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final favData = snapshot.data!.docs[index];
                        final bookId = favData['idLibro'] as String;

                        // Aquí necesitamos obtener los detalles del libro
                        // Esto podría hacerse con un FutureBuilder individual para cada carta
                        // Ojo con el rendimiento: idealmente traer todo en una query si fuera posible, 
                        // pero Firestore no soporta "WHERE IN" con muchos IDs fácilmente.
                        return FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('libros')
                              .doc(bookId)
                              .get(),
                          builder: (context, bookSnapshot) {
                            if (!bookSnapshot.hasData) return const SizedBox.shrink(); 
                            if (!bookSnapshot.data!.exists) return const SizedBox.shrink(); // Libro borrado?

                            final bookData = Map<String, dynamic>.from(
                              bookSnapshot.data!.data() as Map<String, dynamic>,
                            );
                            // Añadimos el ID al mapa para que navegue bien
                            bookData['id'] = bookSnapshot.data!.id;

                            // Reutilizamos el diseño de carta o creamos uno simple
                            return _FavoriteBookCard(bookData: bookData);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
  }
}

class _FavoriteBookCard extends StatelessWidget {
  final Map<String, dynamic> bookData;

  const _FavoriteBookCard({required this.bookData});

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = bookData['imageUrl'] ?? bookData['imagen'];

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/detalle_libro',
          arguments: bookData,
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image)),
                    )
                  : const Center(child: Icon(Icons.book, size: 50)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bookData['titulo'] ?? 'Sin título',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    bookData['autor'] ?? 'Desconocido',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${bookData['precio'] ?? '0'}',
                        style: const TextStyle(
                          color: Color(0xFF003870),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(Icons.favorite, color: Colors.red, size: 20),
                    ],
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
