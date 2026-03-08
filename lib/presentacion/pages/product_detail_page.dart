import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unimet_marketplace/domain/cubits/cart_cubit.dart';
import 'package:unimet_marketplace/domain/cubits/order_cubit.dart';
import 'package:unimet_marketplace/domain/entities/cart_item.dart';
import '../widgets/paypal_button.dart';

class ProductDetailPage extends StatelessWidget {
  final Map<String, dynamic> productData;

  const ProductDetailPage({super.key, required this.productData});

  void _solicitarLibro(BuildContext context, String price) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesion para realizar esta accion')),
      );
      return;
    }

    if (currentUser.uid == productData['userId']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No puedes solicitar tu propio libro')),
      );
      return;
    }

    try {
      await context.read<OrderCubit>().createOrder(
        sellerId: productData['userId'] ?? '',
        bookId: productData['id'] ?? '',
        bookTitle: productData['titulo'] ?? 'Sin Titulo',
        bookAuthor: productData['autor'] ?? 'Anonimo',
        price: double.tryParse(price) ?? 0.0,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitud enviada exitosamente. El vendedor se pondra en contacto contigo.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar solicitud: $e')),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Intercambio':
        return Colors.orange;
      case 'Donacion':
        return Colors.green;
      case 'Venta':
      default:
        return const Color(0xFF003870);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rawPrice = productData['precio'];
    String price = '0.00';
    if (rawPrice != null) {
      if (rawPrice is num) {
        price = rawPrice.toStringAsFixed(2);
      } else if (rawPrice is String) {
        price = double.tryParse(rawPrice)?.toStringAsFixed(2) ?? rawPrice;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        title: Text(productData['titulo'] ?? 'Detalles del Producto'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductOverview(context, price),
                  const SizedBox(height: 32),
                  _buildProductDescription(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductOverview(BuildContext context, String price) {
    final tipoTransaccion = productData['tipoTransaccion'] ?? 'Venta';
    final isVenta = tipoTransaccion == 'Venta';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        final imageContainer = Container(
          height: isMobile ? 300 : 400,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: const Center(
            child: Icon(Icons.book_rounded, size: 100, color: Colors.grey),
          ),
        );

        final detailsColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              (productData['materia'] as String? ?? 'Sin Categoria').toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF003870),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(tipoTransaccion),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tipoTransaccion.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              productData['titulo'] ?? 'Sin Titulo',
              style: TextStyle(
                fontSize: isMobile ? 24 : 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'por ${productData['autor'] ?? 'Autor Desconocido'}',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '\$ $price',
              style: TextStyle(
                color: const Color(0xFF003870),
                fontSize: isMobile ? 28 : 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            if (isVenta) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final item = CartItem(
                          bookId: productData['id'] ?? UniqueKey().toString(),
                          title: productData['titulo'] ?? 'Sin Titulo',
                          author: productData['autor'] ?? 'Autor Desconocido',
                          price: double.tryParse(price) ?? 0.0,
                          sellerId: productData['userId'] ?? 'system',
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
                        foregroundColor: const Color(0xFF003870),
                        side: const BorderSide(color: Color(0xFF003870)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              PaypalButton(
                amount: price,
                onPaymentSuccess: (data) {                  final bookId = productData['id'] ?? '';
                  if (bookId.isNotEmpty) {
                    context.read<OrderCubit>().markBookAsSold(bookId);
                  }                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('!Pago realizado con exito!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _solicitarLibro(context, price),
                  icon: Icon(tipoTransaccion == 'Intercambio'
                      ? Icons.swap_horiz
                      : Icons.volunteer_activism),
                  label: Text(tipoTransaccion == 'Intercambio'
                      ? 'Solicitar Intercambio'
                      : 'Solicitar Donacion'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003870),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ],
        );

        if (isMobile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              imageContainer,
              const SizedBox(height: 24),
              detailsColumn,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: imageContainer),
            const SizedBox(width: 24),
            Expanded(flex: 3, child: detailsColumn),
          ],
        );
      },
    );
  }

  Widget _buildProductDescription() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Descripcion del Libro',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            productData['descripcion'] ??
                'No hay descripcion disponible para este libro.',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
