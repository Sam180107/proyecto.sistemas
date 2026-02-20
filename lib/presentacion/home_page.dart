import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/auth_cubit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint("HomePage build()");

    final List<Map<String, String>> libros = [
      {'titulo': 'Cálculo de Stewart', 'precio': '\$20', 'estado': 'Nuevo'},
      {'titulo': 'Física Universitaria', 'precio': '\$15', 'estado': 'Usado'},
      {'titulo': 'Derecho Romano', 'precio': '\$10', 'estado': 'Como nuevo'},
      {'titulo': 'Economía Samuelson', 'precio': '\$25', 'estado': 'Nuevo'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        title: const Text(
          'Marketplace Unimet',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              debugPrint("Logout presionado");
              context.read<AuthCubit>().logout();
            },
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Debug útil para Web: confirma tamaños reales
              debugPrint(
                "HomePage constraints: "
                "w=${constraints.maxWidth}, h=${constraints.maxHeight}",
              );

              // Si por alguna razón el tamaño es inválido, no intentamos renderizar el Grid.
              if (constraints.maxWidth <= 0 || constraints.maxHeight <= 0) {
                return const Center(
                  child: Text("Layout inválido (tamaño 0)"),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Libros Disponibles',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Este Expanded + GridView con physics/clamping es lo más estable en Web
                  Expanded(
                    child: GridView.builder(
                      // evita bugs de scroll en Web
                      physics: const ClampingScrollPhysics(),
                      // En algunos casos Web mejora con esto
                      // (si te vuelve a dar blanco, lo activamos)
                      // shrinkWrap: true,
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _columnsForWidth(constraints.maxWidth),
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: libros.length,
                      itemBuilder: (context, index) {
                        final libro = libros[index];
                        return _LibroCard(
                          titulo: libro['titulo'] ?? '',
                          precio: libro['precio'] ?? '',
                          estado: libro['estado'] ?? '',
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint("FAB presionado");
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