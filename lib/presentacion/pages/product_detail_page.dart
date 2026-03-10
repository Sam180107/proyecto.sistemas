import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unimet_marketplace/domain/cubits/cart_cubit.dart';
import 'package:unimet_marketplace/domain/cubits/order_cubit.dart';
import 'package:unimet_marketplace/domain/entities/cart_item.dart';
import '../widgets/paypal_button.dart';
import 'package:unimet_marketplace/domain/cubits/rating_cubit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductDetailPage extends StatelessWidget {
  final Map<String, dynamic> productData;

  const ProductDetailPage({super.key, required this.productData});

  void _solicitarLibro(
    BuildContext context,
    String price,
    String tipoTransaccion,
  ) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesion para realizar esta accion'),
        ),
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
        price: tipoTransaccion == 'Venta'
            ? (double.tryParse(price) ?? 0.0)
            : 0.0,
        tipoTransaccion: tipoTransaccion,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Solicitud de $tipoTransaccion enviada exitosamente. El vendedor se pondra en contacto contigo.',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar solicitud: $e')),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Intercambio':
        return Colors.orange;
      case 'Donacion':
        return Colors.green;
      case 'Venta':
        return const Color(0xFF003870);
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
        actions: [
          if (productData['userId'] != FirebaseAuth.instance.currentUser?.uid)
            IconButton(
              onPressed: () => _mostrarDialogoReporte(context),
              icon: const Icon(Icons.report_problem_outlined, color: Colors.red),
              tooltip: 'Reportar Publicación',
            ),
        ],
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
              ),
            ],
          ),
          child: Center(
            child:
                (productData['imageUrl'] != null ||
                    productData['imagen'] != null)
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      productData['imageUrl'] ?? productData['imagen'],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.book_rounded,
                        size: 100,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : const Icon(Icons.book_rounded, size: 100, color: Colors.grey),
          ),
        );

        final detailsColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              (productData['materia'] as String? ?? 'Sin Categoria')
                  .toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF003870),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
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
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Stock: ${productData['stock'] ?? 1}',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
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
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/perfil',
                  arguments: {
                    'vendedor':
                        productData['vendedor'] ??
                        productData['nombreVendedor'] ??
                        'Vendedor',
                    'carrera': productData['carrera'] ?? 'Estudiante',
                    'iniciales':
                        (productData['vendedor'] ??
                                productData['nombreVendedor'] ??
                                'U')
                            .toString()
                            .substring(0, 1),
                    'userId': productData['userId'],
                    'rol': 'Estudiante',
                    'isOtherUser': true,
                    'libro': productData['titulo'] ?? 'un libro',
                  },
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                alignment: Alignment.centerLeft,
              ),
              child: const Text(
                "Ver Perfil del Vendedor",
                style: TextStyle(
                  color: Color.fromARGB(255, 27, 132, 223),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
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
                          imageUrl:
                              productData['imageUrl'] ?? productData['imagen'],
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
                  const SizedBox(width: 12),
                  _buildWhatsappButton(context),
                ],
              ),
              const SizedBox(height: 12),
              PaypalButton(
                amount: price,
                onPaymentSuccess: (data) {
                  final bookId = productData['id'] ?? '';
                  if (bookId.isNotEmpty) {
                    context.read<OrderCubit>().markBookAsSold(bookId);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('!Pago realizado con exito!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Mostrar diálogo de valoración inmediatamente para el demo
                  _mostrarDialogoValoracion(
                    context,
                    bookId,
                    productData['userId'] ?? '',
                  );
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Simulando proceso de transacción...'),
                        backgroundColor: Colors.blue,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    Future.delayed(const Duration(seconds: 2), () {
                      if (context.mounted) {
                        _mostrarDialogoValoracion(
                          context,
                          productData['id'] ?? '',
                          productData['userId'] ?? '',
                        );
                      }
                    });
                  },
                  icon: const Icon(Icons.shopping_bag_outlined, color: Colors.blue),
                  label: const Text('Simular Compra',
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.blue, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _solicitarLibro(context, price, tipoTransaccion);
                      },
                      icon: Icon(
                        tipoTransaccion == 'Intercambio'
                            ? Icons.swap_horiz
                            : Icons.volunteer_activism,
                      ),
                      label: Text(
                        tipoTransaccion == 'Intercambio'
                            ? 'Solicitar Intercambio'
                            : 'Solicitar Donacion',
                      ),
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
                  const SizedBox(width: 12),
                  _buildWhatsappButton(context),
                ],
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
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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

  Widget _buildWhatsappButton(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          .doc(productData['userId'])
          .snapshots(),
      builder: (context, snapshot) {
        String telefonoFirebase = "";
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          telefonoFirebase = data['telefono'] ?? "";
        }

        if (telefonoFirebase.isEmpty) {
          telefonoFirebase = productData['telefonoVendedor'] ?? "";
        }

        if (telefonoFirebase.isEmpty) return const SizedBox.shrink();

        return IconButton(
          icon: const Icon(Icons.chat, color: Color(0xFF25D366), size: 30),
          onPressed: () async {
            String cleanPhone = telefonoFirebase.replaceAll(
              RegExp(r'[^\d]'),
              '',
            );
            if (cleanPhone.startsWith('0')) {
              cleanPhone = '58${cleanPhone.substring(1)}';
            } else if (cleanPhone.length == 10 &&
                (cleanPhone.startsWith('412') ||
                    cleanPhone.startsWith('414') ||
                    cleanPhone.startsWith('424') ||
                    cleanPhone.startsWith('422'))) {
              cleanPhone = '58$cleanPhone';
            }

            final String mensaje =
                "Hola, estoy interesado en tu libro '${productData['titulo']}' que vi en BookSwap.";
            final Uri whatsappUri = Uri.parse(
              "https://wa.me/$cleanPhone?text=${Uri.encodeComponent(mensaje)}",
            );

            try {
              if (await canLaunchUrl(whatsappUri)) {
                await launchUrl(
                  whatsappUri,
                  mode: LaunchMode.externalApplication,
                );
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No se pudo abrir WhatsApp')),
                  );
                }
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            }
          },
        );
      },
    );
  }

  void _mostrarDialogoReporte(BuildContext context) {
    String motivoSeleccionado = '';
    final TextEditingController motivoController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.report_problem, color: Colors.red),
                SizedBox(width: 8),
                Text('Reportar Publicación'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('¿Cuál es el motivo del reporte?'),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Contenido inapropiado', child: Text('Contenido inapropiado')),
                      DropdownMenuItem(value: 'Información falsa/engañosa', child: Text('Información falsa/engañosa')),
                      DropdownMenuItem(value: 'No cumple con las reglas institucionales', child: Text('No cumple reglas institucionales')),
                      DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                    ],
                    onChanged: (val) {
                      setState(() {
                        motivoSeleccionado = val ?? '';
                      });
                    },
                    hint: const Text('Seleccionar motivo'),
                  ),
                  if (motivoSeleccionado == 'Otro') ...[
                    const SizedBox(height: 10),
                    TextField(
                      controller: motivoController,
                      decoration: const InputDecoration(labelText: 'Especificar motivo', border: OutlineInputBorder()),
                      maxLines: 2,
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
              ElevatedButton(
                onPressed: () async {
                  if (motivoSeleccionado.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, selecciona un motivo')));
                    return;
                  }
                  final motivoFinal = motivoSeleccionado == 'Otro' ? motivoController.text : motivoSeleccionado;
                  if (motivoFinal.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, especifica el motivo')));
                    return;
                  }
                  try {
                    final currUser = FirebaseAuth.instance.currentUser;
                    await FirebaseFirestore.instance.collection('reportes').add({
                      'estado': 'Pendiente',
                      'motivo': motivoFinal,
                      'publicacionId': productData['id'],
                      'tituloPublicacion': productData['titulo'],
                      'vendedorId': productData['userId'],
                      'reportadoPor': currUser?.email ?? 'Anónimo',
                      'fechaReporte': FieldValue.serverTimestamp(),
                      'tipo': 'Publicacion',
                    });
                    if (context.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reporte enviado con éxito'), backgroundColor: Colors.green));
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al enviar reporte: $e'), backgroundColor: Colors.red));
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Enviar Reporte', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _mostrarDialogoValoracion(
    BuildContext context,
    String bookId,
    String sellerId,
  ) {
    int estrellasSeleccionadas = 0;

    // Preparar el cubit para el vendedor
    context.read<RatingCubit>().cargarValoraciones(sellerId);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (contextDialog, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            '¡Transacción Completada!',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '¿Cómo calificarías al vendedor?',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < estrellasSeleccionadas
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 40,
                    ),
                    onPressed: () {
                      setState(() => estrellasSeleccionadas = index + 1);
                    },
                  );
                }),
              ),
              const SizedBox(height: 10),
              Text(
                estrellasSeleccionadas > 0
                    ? '$estrellasSeleccionadas estrella${estrellasSeleccionadas > 1 ? 's' : ''}'
                    : 'Selecciona estrellas',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Omitir', style: TextStyle(color: Colors.grey)),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: estrellasSeleccionadas > 0
                  ? () async {
                      final success = await context
                          .read<RatingCubit>()
                          .enviarValoracion(estrellasSeleccionadas);
                      if (context.mounted) {
                        Navigator.of(dialogContext).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? '¡Gracias por tu valoración!'
                                  : 'Error al guardar valoración',
                            ),
                            backgroundColor: success
                                ? Colors.green
                                : Colors.red,
                          ),
                        );
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003870),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Enviar Valoración'),
            ),
          ],
        ),
      ),
    );
  }
}
