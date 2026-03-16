import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:unimet_marketplace/domain/cubits/rating_cubit.dart';
import 'package:unimet_marketplace/domain/cubits/order_cubit.dart';
import 'package:unimet_marketplace/domain/cubits/cora_cubit.dart';

class DetalleLibroPage extends StatefulWidget {
  const DetalleLibroPage({super.key});

  @override
  State<DetalleLibroPage> createState() => _DetalleLibroPageState();
}

class _DetalleLibroPageState extends State<DetalleLibroPage> {
  bool _mostrarPago = false;

  void _iniciarProcesoDeSolicitud() {
    setState(() {
      _mostrarPago = true;
    });
  }

  // --- LÓGICA DE PAYPAL ---
  void _ejecutarPagoReal(BuildContext context, Map<String, dynamic> arguments) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => PaypalCheckoutView(
          sandboxMode: true,
          clientId: "AYHmMHVwGKu8CBkSEiMHEHBb9xr3SP0uPZ4bmjbwWYxH_5NdkHM7Q6wc3pAVM4Gefr_OF01DXcuSPwGH",
          secretKey: "ENHj2nD99h26jpDsVNvJnwV4ui9N1hOmmFKOL7kPUU6OKcVTq2XM1OokPQEYxM-WWgCn2eaxZlZsvDtR",
          transactions: [
            {
              "amount": {
                "total": arguments['precio'].toString(),
                "currency": "USD",
                "details": {
                  "subtotal": arguments['precio'].toString(),
                  "shipping": '0',
                  "shipping_discount": 0
                }
              },
              "description": "Compra de material: ${arguments['titulo']} en BookSwap UNIMET",
              "item_list": {
                "items": [
                  {
                    "name": arguments['titulo'] ?? "Libro",
                    "quantity": 1,
                    "price": arguments['precio'].toString(),
                    "currency": "USD"
                  }
                ],
              }
            }
          ],
          note: "Pago procesado por BookSwap.",
          onSuccess: (Map params) async {
            await _finalizarPedidoEnFirebase(context, arguments);
          },
          onError: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error en la pasarela de pago: $error')),
            );
          },
          onCancel: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pago cancelado')),
            );
          },
        ),
      ),
    );
  }

  Future<void> _finalizarPedidoEnFirebase(BuildContext context, Map<String, dynamic> arguments) async {
    try {
      await context.read<OrderCubit>().createOrder(
            sellerId: arguments['userId'],
            bookId: arguments['id'] ?? '',
            bookTitle: arguments['titulo'],
            bookAuthor: arguments['autor'] ?? '',
            price: double.tryParse(arguments['precio'].toString()) ?? 0.0,
            tipoTransaccion: 'Venta',
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Pago exitoso! Solicitud enviada al vendedor.')),
      );
      Navigator.pop(context);
    } catch (e) {
      debugPrint("Error al registrar orden: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

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
                _buildHeader(context, arguments['precio'] ?? 0.0, arguments['imagen'] ?? arguments['imageUrl'] ?? '', arguments),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(arguments['titulo'] ?? 'Sin título', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      Text(arguments['autor'] ?? 'Anónimo', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 16, color: (arguments['stock'] ?? 0) > 0 ? Colors.green : Colors.red),
                          const SizedBox(width: 8),
                          Text("Stock: ${arguments['stock'] ?? 0}", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: (arguments['stock'] ?? 0) > 0 ? Colors.green[700] : Colors.red)),
                        ],
                      ),
                      const SizedBox(height: 25),
                      const Text("Estado de la Transacción", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),
                      _buildStatusTimeline(),
                      const SizedBox(height: 25),
                      _buildInfoCard("Descripción", arguments['descripcion'] ?? 'Sin descripción'),
                      const SizedBox(height: 25),
                      _buildSellerCard(context, arguments),
                      if (_mostrarPago) ...[
                        const SizedBox(height: 25),
                        _buildPayPalSection(context, arguments),
                      ],
                      const SizedBox(height: 180), 
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 45,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.9),
              child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
            ),
          ),
          if (!_mostrarPago)
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

  Widget _buildBottomButton(BuildContext context, Map<String, dynamic> arguments) {
    final isOwner = FirebaseAuth.instance.currentUser?.uid == arguments['userId'];

    if (isOwner) {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: const Text("Tu Publicación", style: TextStyle(color: Colors.white, fontSize: 18)),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // --- BOTÓN DE WHATSAPP CON DATOS EN TIEMPO REAL ---
        StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('usuarios')
              .doc(arguments['userId'])
              .snapshots(),
          builder: (context, snapshot) {
            String telefonoFirebase = "";
            if (snapshot.hasData && snapshot.data!.exists) {
              final data = snapshot.data!.data() as Map<String, dynamic>;
              telefonoFirebase = data['telefono'] ?? "";
            }

            return Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: IconButton(
                onPressed: () async {
                  if (telefonoFirebase.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('El vendedor no tiene teléfono registrado')),
                    );
                    return;
                  }

                  // 1. Limpieza total (solo dígitos)
                  String cleanPhone = telefonoFirebase.replaceAll(RegExp(r'[^\d]'), '');

                  // 2. Estandarización para Venezuela
                  if (cleanPhone.startsWith('0')) {
                    cleanPhone = '58${cleanPhone.substring(1)}';
                  } else if (cleanPhone.length == 10 && (
                      cleanPhone.startsWith('412') || 
                      cleanPhone.startsWith('414') || 
                      cleanPhone.startsWith('424') || 
                      cleanPhone.startsWith('422'))) {
                    cleanPhone = '58$cleanPhone';
                  }

                  final String nombre = arguments['vendedor'] ?? "Vendedor";
                  final String nombreLibro = arguments['titulo'] ?? "Material";
                  final String mensaje = "Hola $nombre, estoy interesado en tu libro '$nombreLibro' que vi en BookSwap.";
                  
                  final Uri whatsappUri = Uri.parse(
                      "https://wa.me/$cleanPhone?text=${Uri.encodeComponent(mensaje)}");

                  if (await canLaunchUrl(whatsappUri)) {
                    await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No se pudo abrir WhatsApp')),
                      );
                    }
                  }
                },
                icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Color(0xFF25D366), size: 30),
              ),
            );
          },
        ),
        const SizedBox(width: 15),
        // Botón azul ovalado - Ancho de 300
        SizedBox(
          width: 380, 
          child: ElevatedButton(
            onPressed: () => _iniciarProcesoDeSolicitud(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
              minimumSize: const Size(0, 60),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text("Solicitar Material", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  // --- FUNCIONES AUXILIARES DE UI ---

  Widget _buildPayPalSection(BuildContext context, Map<String, dynamic> arguments) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF003087), width: 2),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.payment, color: Color(0xFF003087)),
              SizedBox(width: 10),
              Text("Checkout Seguro", style: TextStyle(color: Color(0xFF003087), fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 15),
          Text("Total a pagar: \$${arguments['precio']}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _ejecutarPagoReal(context, arguments),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC439),
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Pagar con PayPal", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () => setState(() => _mostrarPago = false),
            child: const Text("Cancelar", style: TextStyle(color: Colors.red)),
          )
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic precio, String rutaImagen, Map<String, dynamic> arguments) {
    return SizedBox(
      height: 320,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.grey[300],
              child: rutaImagen.startsWith('http')
                  ? Image.network(rutaImagen, fit: BoxFit.cover)
                  : Image.asset(rutaImagen, fit: BoxFit.cover),
            ),
          ),
          Positioned(
            top: 45,
            right: 20,
            child: Row(
              children: [
                _buildCircularAction(
                  icon: Icons.share_outlined,
                  onPressed: () {
                    Share.share('¡Mira este material en BookSwap UNIMET!\n\n${arguments['titulo']}\nPrecio: \$${arguments['precio']}');
                  },
                ),
                const SizedBox(width: 12),
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('usuarios')
                      .doc(FirebaseAuth.instance.currentUser?.uid)
                      .collection('favoritos')
                      .doc(arguments['id'])
                      .snapshots(),
                  builder: (context, snapshot) {
                    bool esFavorito = snapshot.hasData && snapshot.data!.exists;
                    return _buildCircularAction(
                      icon: esFavorito ? Icons.favorite : Icons.favorite_border,
                      iconColor: esFavorito ? Colors.red : Colors.black,
                      onPressed: () {
                        final userId = FirebaseAuth.instance.currentUser?.uid;
                        if (userId == null) return;
                        context.read<CoraCubit>().toggleFavorito(arguments['id'], esFavorito);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8)],
              ),
              child: Text(
                "VENTA - \$ ${precio.toString()}",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularAction({required IconData icon, required VoidCallback onPressed, Color iconColor = Colors.black}) {
    return Container(
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
      child: IconButton(icon: Icon(icon, color: iconColor), onPressed: onPressed),
    );
  }

  Widget _buildStatusTimeline() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _statusItem("Disponible", Icons.check_circle, true),
          Expanded(child: Divider(indent: 10, endIndent: 10, color: Colors.grey[300])),
          _statusItem("Solicitado", Icons.radio_button_unchecked, false),
          Expanded(child: Divider(indent: 10, endIndent: 10, color: Colors.grey[300])),
          _statusItem("Aceptado", Icons.radio_button_unchecked, false),
        ],
      ),
    );
  }

  Widget _statusItem(String label, IconData icon, bool active) {
    return Column(
      children: [
        Icon(icon, color: active ? const Color(0xFF1E88E5) : Colors.grey, size: 24),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(fontSize: 10, color: active ? Colors.black : Colors.grey)),
      ],
    );
  }

  Widget _buildInfoCard(String titulo, String contenido) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          Text(contenido, style: const TextStyle(color: Colors.black87, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildSellerCard(BuildContext context, Map<String, dynamic> arguments) {
    return BlocBuilder<RatingCubit, RatingState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: const Color(0xFF003870),
                child: Text(arguments['iniciales'] ?? '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(arguments['vendedor'] ?? 'Vendedor', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(arguments['carrera'] ?? 'Carrera no especificada', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/perfil', arguments: {
                    ...arguments,
                    'isOtherUser': true,
                  });
                },
                child: const Text("Ver Perfil", style: TextStyle(color: Color(0xFF1E88E5), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }
}