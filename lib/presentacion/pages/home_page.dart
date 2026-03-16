import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';

// Imports de tu proyecto
import '../../domain/cubits/search_cubit.dart';
import '../widgets/custom_app_bar.dart';
import 'package:unimet_marketplace/domain/cubits/cora_cubit.dart';

// 1. Modelo de datos (Data)
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
    'descripcion': 'Libro en excelente estado, edición 8va.',
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
    'descripcion': 'Casi nuevo, incluye el solucionario impreso.',
  },
];

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchCubit(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F4F7),
        appBar: const CustomAppBar(),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Explorar Material Académico',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Encuentra libros y material de estudio para tus cursos',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 20),
                    
                    BlocBuilder<SearchCubit, SearchState>(
                      builder: (context, state) {
                        if (state is SearchInitial || state is SearchLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (state is SearchError) {
                          return Center(child: Text(state.message));
                        }
                        if (state is SearchLoaded) {
                          if (state.results.isEmpty) {
                            return const Center(
                              child: Text('No se encontraron publicaciones.'),
                            );
                          }

                          return LayoutBuilder(
                            builder: (context, constraints) {
                              int crossAxisCount = constraints.maxWidth < 600 ? 2 : (constraints.maxWidth < 900 ? 3 : 4);

                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.68,
                                ),
                                itemCount: state.results.length,
                                itemBuilder: (context, index) {
                                  final doc = state.results[index];
                                  final data = doc.data() as Map<String, dynamic>;
                                  data['id'] = doc.id; 
                                  return _buildBookCard(context, data);
                                },
                              );
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 16,
              child: FloatingActionButton(
                mini: true,
                heroTag: 'fav_btn',
                backgroundColor: Colors.white,
                onPressed: () => Navigator.pushNamed(context, '/favorites'),
                child: const Icon(Icons.favorite, color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookCard(BuildContext context, Map<String, dynamic> data) {
    return StatefulBuilder(
      builder: (context, setState) {
        final String libroId = data['id'] ?? '';
        bool isHovered = false;

        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: isHovered ? (Matrix4.identity()..translate(0, -5, 0)) : Matrix4.identity(),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isHovered ? Colors.black.withOpacity(0.15) : Colors.black.withOpacity(0.05),
                  blurRadius: isHovered ? 15 : 10,
                  spreadRadius: isHovered ? 4 : 2,
                ),
              ],
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/detalle_libro',
                  arguments: {
                    ...data,
                    'imagen': data['imageUrl'] ?? 'assets/images/book_placeholder.png',
                    'tipoTransaccion': data['tipoTransaccion'] ?? data['tipo'] ?? 'Venta',
                  },
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          child: Container(
                            width: double.infinity,
                            color: Colors.grey[100],
                            child: data['imageUrl'] != null
                                ? Image.network(
                                    data['imageUrl'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Center(child: Icon(Icons.book, size: 40, color: Colors.grey)),
                                  )
                                : const Center(child: Icon(Icons.book, size: 40, color: Colors.grey)),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: (data['tipoTransaccion'] ?? data['tipo']) == 'Intercambio'
                                  ? const Color(0xFF4CAF50).withOpacity(0.9)
                                  : const Color(0xFF1976D2).withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              (data['tipoTransaccion'] ?? data['tipo'] ?? 'Venta').toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('usuarios')
                                .doc(FirebaseAuth.instance.currentUser?.uid)
                                .collection('favoritos')
                                .doc(libroId)
                                .snapshots(),
                            builder: (context, snapshot) {
                              final bool estaEnFavoritos = snapshot.hasData && snapshot.data!.exists;
                              return _HoverIconButton(
                                icon: Icons.favorite_border,
                                activeIcon: Icons.favorite,
                                activeColor: Colors.red,
                                isSelected: estaEnFavoritos,
                                onPressed: () => context.read<CoraCubit>().toggleFavorito(libroId, estaEnFavoritos),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (data['categoria'] ?? data['materia'] ?? 'General').toUpperCase(),
                          style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data['titulo'] ?? 'Sin título',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          (data['tipoTransaccion'] ?? data['tipo']) == 'Intercambio'
                              ? 'Trueque'
                              : "\$ ${data['precio'] ?? '0.00'}",
                          style: TextStyle(
                            color: (data['tipoTransaccion'] ?? data['tipo']) == 'Intercambio'
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFF1976D2),
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
          ),
        );
      },
    );
  }
}

// ESTA ES LA CLASE QUE FALTABA
class _HoverIconButton extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final Color activeColor;
  final bool isSelected;
  final VoidCallback onPressed;

  const _HoverIconButton({
    required this.icon,
    required this.activeIcon,
    required this.activeColor,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected ? activeColor : Colors.grey,
        ),
        onPressed: onPressed,
        constraints: const BoxConstraints(),
        padding: const EdgeInsets.all(8),
      ),
    );
  }
}