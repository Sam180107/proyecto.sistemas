import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unimet_marketplace/domain/cubits/rating_cubit.dart';
import 'package:unimet_marketplace/domain/cubits/order_cubit.dart';
import 'package:unimet_marketplace/domain/cubits/cart_cubit.dart';
import 'package:unimet_marketplace/domain/entities/cart_item.dart';
import '../widgets/paypal_button.dart';
import 'publicar_libro_page.dart';

class DetalleLibroPage extends StatelessWidget {
  const DetalleLibroPage({super.key});

  void _solicitarLibro(
    BuildContext context,
    Map<String, dynamic> arguments,
  ) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para solicitar un libro'),
        ),
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
        tipoTransaccion: 'Venta',
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitud enviada exitosamente')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al enviar solicitud: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Extraemos los argumentos de forma segura
    final rawArguments = ModalRoute.of(context)?.settings.arguments;
    if (rawArguments == null || rawArguments is! Map<String, dynamic>) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('No se pudo cargar la información del libro')),
      );
    }
    final arguments = rawArguments;

    // Cargar valoraciones del vendedor
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.read<RatingCubit>().cargarValoraciones(arguments['userId'] ?? '');
      }
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
                  arguments['precio'] ?? 0.0,
                  arguments['imagen'] ?? arguments['imageUrl'] ?? '',
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        arguments['titulo'] ?? 'Sin título',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        arguments['autor'] == null || arguments['autor'].isEmpty
                            ? 'Anónimo'
                            : arguments['autor']!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 16, color: (arguments['stock'] ?? 0) > 0 ? Colors.green : Colors.red),
                          const SizedBox(width: 8),
                          Text(
                            "Stock: ${arguments['stock'] ?? 0}",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: (arguments['stock'] ?? 0) > 0 ? Colors.green[700] : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),

                      const Text(
                        "Estado del Material",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildStatusTimeline(arguments['estado']),

                      const SizedBox(height: 25),
                      _buildInfoCard(
                        "Descripción",
                        arguments['descripcion'] ?? 'Sin descripción',
                      ),

                      const SizedBox(height: 25),
                      _buildSellerCard(context, arguments),

                      // Espacio final para que el scroll permita ver todo antes del botón
                        const SizedBox(height: 180),
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
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _buildBottomButton(context, arguments),
          ),
        ),
      );
    }

  // --- WIDGETS DE APOYO OPTIMIZADOS ---

  Widget _buildHeader(BuildContext context, dynamic precio, String rutaImagen) {
    return SizedBox(
      height: 320,
      width: double.infinity,
      child: Stack(
        children: [
          // Imagen con respaldo por si falla la ruta
          Positioned.fill(
            child: Container(
              color: Colors.grey[300],
              child: rutaImagen.startsWith('http')
                  ? Image.network(
                      rutaImagen,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey,
                          ),
                        );
                      },
                    )
                  : Image.asset(
                      rutaImagen,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
            ),
          ),
          // Gradiente para que el botón de volver se vea mejor
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
          // Etiqueta de precio
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

  Widget _buildStatusTimeline(String? currentStatus) {
    final status = currentStatus ?? 'Disponible';
    
    bool isDisponible = status == 'Disponible';
    bool isSolicitado = status == 'Solicitado';
    bool isEntregado = status == 'Entregado' || status == 'Vendido';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _statusItem("Disponible", isDisponible ? Icons.check_circle : Icons.check_circle_outline, isDisponible || isSolicitado || isEntregado),
          Expanded(
            child: Divider(indent: 10, endIndent: 10, color: (isSolicitado || isEntregado) ? const Color(0xFF1E88E5) : Colors.grey[300]),
          ),
          _statusItem("Solicitado", isSolicitado ? Icons.pending : Icons.pending_outlined, isSolicitado || isEntregado),
          Expanded(
            child: Divider(indent: 10, endIndent: 10, color: isEntregado ? const Color(0xFF1E88E5) : Colors.grey[300]),
          ),
          _statusItem("Entregado", isEntregado ? Icons.task_alt : Icons.radio_button_unchecked, isEntregado),
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

  Widget _buildSellerCard(
    BuildContext context,
    Map<String, dynamic> arguments,
  ) {
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
                    if (state is RatingLoaded &&
                        state.totalValoraciones > 0) ...[
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          _buildStarRating(state.promedio),
                          const SizedBox(width: 5),
                          Text(
                            '${state.promedio.toStringAsFixed(1)} (${state.totalValoraciones})',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
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
          index < rating.floor()
              ? Icons.star
              : (index < rating && rating % 1 != 0)
              ? Icons.star_half
              : Icons.star_border,
          color: Colors.amber,
          size: 14,
        );
      }),
    );
  }

  Widget _buildBottomButton(
    BuildContext context,
    Map<String, dynamic> arguments,
  ) {
    final isOwner =
        FirebaseAuth.instance.currentUser?.uid == arguments['userId'];

    final rawPrice = arguments['precio'];
    String price = '0.00';
    if (rawPrice != null) {
      if (rawPrice is num) {
        price = rawPrice.toStringAsFixed(2);
      } else if (rawPrice is String) {
        price = double.tryParse(rawPrice)?.toStringAsFixed(2) ?? rawPrice;
      }
    }

    final isVenta = arguments['tipoTransaccion'] == 'Venta' || arguments['tipo'] == 'Venta';
    final estado = arguments['estado'] ?? 'Disponible';
    final isSolicitado = estado == 'Solicitado';
    final isEntregado = estado == 'Entregado' || estado == 'Vendido';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isOwner || !isVenta || !isEntregado)
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                if (!isSolicitado && !isEntregado)
                  BoxShadow(
                    color: const Color(0xFF1E88E5).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
              ],
            ),
            child: ElevatedButton(
              onPressed: (isSolicitado || isEntregado) && !isOwner
                  ? null
                  : () {
                      if (isOwner) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PublicarLibroPage(
                              bookData: arguments,
                              bookId: arguments['id'],
                            ),
                          ),
                        );
                      } else {
                        _solicitarLibro(context, arguments);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: isOwner
                    ? const Color(0xFF1E88E5)
                    : (isSolicitado || isEntregado
                        ? Colors.grey[400]
                        : const Color(0xFF1E88E5)),
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 0,
              ),
              child: Text(
                isOwner
                    ? "Editar Publicación"
                    : (isEntregado
                        ? "Entregado"
                        : (isSolicitado ? "Solicitado" : "Solicitar Material")),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        if (isVenta && !isOwner && !isSolicitado && !isEntregado &&
            double.tryParse(price) != null &&
            double.parse(price) > 0) ...[
          if (!isVenta) const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final item = CartItem(
                  bookId: arguments['id'] ?? UniqueKey().toString(),
                  title: arguments['titulo'] ?? 'Sin Título',
                  author: arguments['autor'] ?? 'Autor Desconocido',
                  price: double.tryParse(price) ?? 0.0,
                  sellerId: arguments['userId'] ?? 'system',
                  imageUrl: arguments['imageUrl'] ?? arguments['imagen'] ?? '',
                );
                context.read<CartCubit>().addItem(item);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Agregado al carrito'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Agregar al Carrito'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1E88E5),
                side: const BorderSide(color: Color(0xFF1E88E5)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          PaypalButton(
            amount: price,
            onPaymentSuccess: (data) {
              if (!context.mounted) return;
              final bookId = arguments['id'] ?? '';
              if (bookId.isNotEmpty) {
                context.read<OrderCubit>().markBookAsSold(bookId);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('¡Pago realizado con éxito!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (!context.mounted) return;
                final bookId = arguments['id'] ?? '';
                if (bookId.isNotEmpty) {
                  context.read<OrderCubit>().markBookAsSold(bookId);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('¡Simulación de pago exitosa!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              icon: const Icon(Icons.bug_report),
              label: const Text('Simular Pago (Prueba)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
