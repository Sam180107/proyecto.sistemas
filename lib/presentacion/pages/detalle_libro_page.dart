import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unimet_marketplace/domain/cubits/rating_cubit.dart';
import 'package:unimet_marketplace/domain/cubits/order_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unimet_marketplace/domain/cubits/cora_cubit.dart';
import 'package:share_plus/share_plus.dart'; // Para la funcionalidad del botón de compartir


class DetalleLibroPage extends StatelessWidget {
  const DetalleLibroPage({super.key});

  void _solicitarLibro(BuildContext context, Map<String, dynamic> arguments) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para solicitar un libro')),
      );
      return;
    }

    if (currentUser.uid == arguments['userId']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No puedes solicitar tu propio libro')),
      );
      return;
    }

    try {
      await context.read<OrderCubit>().createOrder(
        sellerId: arguments['userId'],
        bookId: arguments['id'] ?? '',
        bookTitle: arguments['titulo'],
        bookAuthor: arguments['autor'] ?? '',
        price: double.tryParse(arguments['precio'].toString()) ?? 0.0,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitud enviada exitosamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar solicitud: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Extraemos los argumentos de forma segura
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    // Cargar valoraciones del vendedor
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RatingCubit>().cargarValoraciones(arguments['userId']);
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Cabecera con Imagen y Precio
                _buildHeader(
                  context,
                  arguments['precio']!,
                  arguments['imagen']!,
                  arguments,
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        arguments['titulo']!,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        arguments['autor'] == null || arguments['autor'].isEmpty ? 'Anónimo' : arguments['autor']!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 25),

                      const Text(
                        "Estado de la Transacción",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildStatusTimeline(),

                      const SizedBox(height: 25),
                      _buildInfoCard("Descripción", arguments['descripcion']!),

                      const SizedBox(height: 25),
                      _buildSellerCard(
                        context,
                        arguments,
                      ),

                      // Espacio final para que el scroll permita ver todo antes del botón
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. BOTÓN DE RETROCESO (Indispensable al usar Stack)
          Positioned(
            top: 45,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white.withValues(alpha: 0.9),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // 3. BOTÓN DE ACCIÓN FIJO EN LA PARTE INFERIOR
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: _buildBottomButton(context, arguments),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS DE APOYO OPTIMIZADOS ---

  Widget _buildHeader(BuildContext context, dynamic precio, String rutaImagen, Map<String, dynamic> arguments) {
  final String libroId = arguments['id'] ?? ''; // Asegúrate de pasar el ID del libro en los argumentos

  return SizedBox(
    height: 320,
    width: double.infinity,
    child: Stack(
      children: [
        // 1. Imagen de fondo
        Positioned.fill(
          child: Container(
            color: Colors.grey[300],
            child: rutaImagen.startsWith('http')
                ? Image.network(rutaImagen, fit: BoxFit.cover)
                : Image.asset(rutaImagen, fit: BoxFit.cover),
          ),
        ),
        
        // 2. Gradiente superior para visibilidad de botones
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.transparent,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // 3. BOTONES DE ACCIÓN (Favorito y Compartir)
        Positioned(
          top: 45, // Alineado con el botón de retroceder
          right: 20,
          child: Row(
            children: [
              // --- BOTÓN DE FAVORITO CON FIREBASE ---
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('usuarios')
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .collection('favoritos')
                    .doc(libroId)
                    .snapshots(),
                builder: (context, snapshot) {
                  bool esFavorito = snapshot.hasData && snapshot.data!.exists;

                  return _buildCircularAction(
                    icon: esFavorito ? Icons.favorite : Icons.favorite_border,
                    color: esFavorito ? Colors.red : Colors.black,
                    onPressed: () => context.read<CoraCubit>().toggleFavorito(libroId, esFavorito),
                  );
                },
              ),
              const SizedBox(width: 12),
              
              // --- BOTÓN DE COMPARTIR ---
              _buildCircularAction(
                icon: Icons.share_outlined,
                color: Colors.black,
                onPressed: () {
                  // Necesitas importar 'package:share_plus/share_plus.dart'
                  Share.share(
                    '¡Mira este material en BookSwap! "${arguments['titulo']}" por \$${precio.toString()}. Encuéntralo en el campus de la UNIMET.',
                    subject: 'Material Académico BookSwap',
                  );
                },
              ),
            ],
          ),
        ),

        // 4. Etiqueta de precio (Tu código original)
        Positioned(
          bottom: 20,
          left: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E88E5),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Text(
              "VENTA - \$ ${precio.toString()}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

// Widget auxiliar para mantener el estilo circular y la sombra
Widget _buildCircularAction({required IconData icon, required Color color, required VoidCallback onPressed}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.9),
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: IconButton(
      icon: Icon(icon, color: color, size: 22),
      onPressed: onPressed,
    ),
  );
}

  Widget _buildStatusTimeline() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _statusItem("Disponible", Icons.check_circle, true),
          Expanded(
            child: Divider(indent: 10, endIndent: 10, color: Colors.grey[300]),
          ),
          _statusItem("Solicitado", Icons.radio_button_unchecked, false),
          Expanded(
            child: Divider(indent: 10, endIndent: 10, color: Colors.grey[300]),
          ),
          _statusItem("Aceptado", Icons.radio_button_unchecked, false),
        ],
      ),
    );
  }

  Widget _statusItem(String label, IconData icon, bool active) {
    return Column(
      children: [
        Icon(
          icon,
          color: active ? const Color(0xFF1E88E5) : Colors.grey,
          size: 24,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            color: active ? Colors.black : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String titulo, String contenido) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Text(
            contenido,
            style: const TextStyle(
              color: Colors.black87,
              height: 1.5,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerCard(BuildContext context, Map<String, dynamic> arguments) {
  String nombre = arguments['vendedor']!;
  String carrera = arguments['carrera']!;
  String iniciales = arguments['iniciales']!;
  
  return BlocBuilder<RatingCubit, RatingState>(
    builder: (context, state) {
      return Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFF003870),
              child: Text(
                iniciales,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    carrera,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  if (state is RatingLoaded && state.totalValoraciones > 0) ...[
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        _buildStarRating(state.promedio),
                        const SizedBox(width: 5),
                        Text(
                          '${state.promedio.toStringAsFixed(1)} (${state.totalValoraciones})',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/perfil',
                  arguments: {
                    'vendedor': arguments['vendedor'],
                    'carrera': arguments['carrera'],
                    'iniciales': arguments['iniciales'],
                    'userId': arguments['userId'],
                    'rol': arguments['rol'],
                    'isOtherUser': true,
                    // --- CORRECCIÓN AQUÍ ---
                    // Si en la lista de libros el campo viene como 'telefono', pásalo directamente
                   // En el Navigator.pushNamed de _buildSellerCard
                    'telefono': arguments['telefonoVendedor'] ?? arguments['telefono'] ?? arguments['celular'] ?? '',
                    'libro': arguments['titulo'] ?? 'un libro', 
                  },
                );
              },
              child: const Text(
                "Ver Perfil",
                style: TextStyle(
                  color: Color(0xFF1E88E5),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor() ? Icons.star :
          (index < rating && rating % 1 != 0) ? Icons.star_half : Icons.star_border,
          color: Colors.amber,
          size: 14,
        );
      }),
    );
  }

  Widget _buildBottomButton(BuildContext context, Map<String, dynamic> arguments) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E88E5).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => _solicitarLibro(context, arguments),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E88E5),
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 0,
        ),
        child: const Text(
          "Solicitar Material",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
