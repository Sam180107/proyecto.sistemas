import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/cubits/search_cubit.dart';
import '../widgets/custom_app_bar.dart';
import 'package:unimet_marketplace/domain/cubits/cora_cubit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Estado local para controlar si el filtro de favoritos está activo
  bool mostrarSoloFavoritos = false;

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
                          // --- LÓGICA DE FILTRADO ---
                          var resultadosMostrados = state.results;

                          if (mostrarSoloFavoritos) {
                            // Escuchamos la lista de IDs del CoraCubit
                            final listaFavoritos = context.watch<CoraCubit>().state;
                            resultadosMostrados = resultadosMostrados.where((doc) {
                              return listaFavoritos.contains(doc.id);
                            }).toList();
                          }

                          if (resultadosMostrados.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 40),
                                child: Text('No se encontraron publicaciones en esta categoría.'),
                              ),
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
                                itemCount: resultadosMostrados.length,
                                itemBuilder: (context, index) {
                                  final doc = resultadosMostrados[index];
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
            
            // --- BOTÓN FLOTANTE (CORAZÓN DE FILTRO) ---
            Positioned(
              top: 10,
              right: 16,
              child: FloatingActionButton(
                mini: true,
                heroTag: 'fav_btn_main',
                // Cambia de color si el filtro está encendido
                backgroundColor: mostrarSoloFavoritos ? Colors.red : Colors.white,
                onPressed: () {
                  setState(() {
                    mostrarSoloFavoritos = !mostrarSoloFavoritos;
                  });
                },
                child: Icon(
                  Icons.favorite, 
                  color: mostrarSoloFavoritos ? Colors.white : Colors.red
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookCard(BuildContext context, Map<String, dynamic> data) {
    // Usamos StatefulBuilder solo para el efecto de Hover interno
    return StatefulBuilder(
      builder: (context, cardSetState) {
        final String libroId = data['id'] ?? '';
        bool isHovered = false;

        // Escuchamos la lista de favoritos del Cubit para saber si este libro está marcado
        final listaIdsFavoritos = context.watch<CoraCubit>().state;
        final bool estaEnFavoritos = listaIdsFavoritos.contains(libroId);

        return MouseRegion(
          onEnter: (_) => cardSetState(() => isHovered = true),
          onExit: (_) => cardSetState(() => isHovered = false),
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
                        // Badge de Tipo de Transacción
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
                        // --- CORAZÓN DE CADA TARJETA ---
                        Positioned(
                          top: 12,
                          right: 12,
                          child: _HoverIconButton(
                            icon: Icons.favorite_border,
                            activeIcon: Icons.favorite,
                            activeColor: Colors.red,
                            isSelected: estaEnFavoritos,
                            onPressed: () => context.read<CoraCubit>().toggleFavorito(libroId, estaEnFavoritos),
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

// Widget auxiliar para el botón de favorito con fondo circular
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
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, spreadRadius: 1)
        ]
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