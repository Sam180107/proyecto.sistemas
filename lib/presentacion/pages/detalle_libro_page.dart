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
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DetalleLibroPage extends StatefulWidget {
  const DetalleLibroPage({super.key});

  @override
  State<DetalleLibroPage> createState() => _DetalleLibroPageState();
}

class _DetalleLibroPageState extends State<DetalleLibroPage> {
  bool _mostrarPago = false;

  void _iniciarProcesoDeSolicitud() {
    setState(() => _mostrarPago = true);
  }

  // --- NUEVA LÓGICA DE EDICIÓN ---
void _mostrarDialogoEditar(BuildContext context, Map<String, dynamic> arguments) {
  final TextEditingController tituloCtrl = TextEditingController(text: arguments['titulo'] ?? '');
  final TextEditingController autorCtrl = TextEditingController(text: arguments['autor'] ?? '');
  final TextEditingController descCtrl = TextEditingController(text: arguments['descripcion'] ?? '');
  final TextEditingController precioCtrl = TextEditingController(text: arguments['precio'].toString());
  final TextEditingController stockCtrl = TextEditingController(text: (arguments['stock'] ?? 0).toString());
  final String libroId = arguments['id'] ?? '';
  
  
  final double anchoPantalla = MediaQuery.of(context).size.width;

  XFile? imagenSeleccionada;
  bool subiendo = false;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titlePadding: EdgeInsets.zero,
        title: Container(
          
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: const BoxDecoration(
            color: Color(0xFF1E88E5),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: const Center(
            child: Text("Actualizar Publicación", 
              
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26)),
          ),
        ),
        
        content: SizedBox(
          
          width: anchoPantalla * 0.9, 
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                
                const SizedBox(height: 40),
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final foto = await picker.pickImage(source: ImageSource.gallery);
                    if (foto != null) setDialogState(() => imagenSeleccionada = foto);
                  },
                  child: Container(
                    
                    height: 180, 
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blue[50], 
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue[100]!, width: 2),
                      image: imagenSeleccionada != null 
                        ? DecorationImage(image: FileImage(File(imagenSeleccionada!.path)), fit: BoxFit.cover)
                        : (arguments['imageUrl'] != null ? DecorationImage(image: NetworkImage(arguments['imageUrl']), fit: BoxFit.cover) : null),
                    ),
                    child: (imagenSeleccionada == null && (arguments['imageUrl'] == null))
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            
                            Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.blue[400]),
                            Text("Subir foto", style: TextStyle(color: Colors.blue[400])),
                          ],
                        )
                      : Align(
                          alignment: Alignment.bottomRight, 
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                            child: const Icon(Icons.edit, color: Colors.white, size: 20),
                          ),
                        ),
                  ),
                ),
                
                const SizedBox(height: 20),
                _buildModernField(tituloCtrl, "Título del material", Icons.book),
                _buildModernField(autorCtrl, "Autor", Icons.person_outline),
                Row(
                  children: [
                    Expanded(child: _buildModernField(precioCtrl, "Precio (\$)", Icons.attach_money, isNumber: true)),
                    
                    const SizedBox(width: 10),
                    Expanded(child: _buildModernField(stockCtrl, "Stock", Icons.inventory_2, isNumber: true)),
                  ],
                ),
                _buildModernField(descCtrl, "Descripción", Icons.description_outlined, maxLines: 3),
              ],
            ),
          ),
        ),
        
        actionsPadding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext), 
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: subiendo ? null : () async {
              setDialogState(() => subiendo = true);
              try {
                String? nuevaUrl;
                if (imagenSeleccionada != null) {
                  final bytes = await imagenSeleccionada!.readAsBytes();
                  final fileName = 'edit_${DateTime.now().millisecondsSinceEpoch}.jpg';
                  await Supabase.instance.client.storage.from('libros_imagenes').uploadBinary(fileName, bytes);
                  nuevaUrl = Supabase.instance.client.storage.from('libros_imagenes').getPublicUrl(fileName);
                }

                
                final Map<String, dynamic> datosParaActualizar = {
                  'titulo': tituloCtrl.text,
                  'autor': autorCtrl.text,
                  'precio': double.tryParse(precioCtrl.text) ?? 0.0,
                  'stock': int.tryParse(stockCtrl.text) ?? 0,
                  'descripcion': descCtrl.text,
                };
                
                if (nuevaUrl != null) {
                  datosParaActualizar['imageUrl'] = nuevaUrl;
                }

                await FirebaseFirestore.instance.collection('libros').doc(libroId).update(datosParaActualizar);
                
                if (context.mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(backgroundColor: Colors.green, content: Text("¡Actualizado con éxito!")),
                  );
                }
              } catch (e) { 
                setDialogState(() => subiendo = false); 
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
              
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: subiendo 
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
              : const Text("Guardar Cambios", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildModernField(TextEditingController controller, String label, IconData icon, {bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF1E88E5), size: 22),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  // --- LÓGICA DE PAYPAL ---
  void _ejecutarPagoReal(BuildContext context, Map<String, dynamic> arguments) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => PaypalCheckoutView(
          sandboxMode: true,
          clientId: "AYHmMHVwGKu8CBkSEiMHEHBb9xr3SP0uPZ4bmjbwWYxH_5NdkHM7Q6wc3pAVM4Gefr_OF01DXcuSPwGH",
          secretKey: "ENHj2nD99h26jpDsVNvJnwV4ui9N1hOmmFKOL7kPUU6OKcVTq2XM1OokPQEYxM-WWgCn2eaxZlZsvDtR",
          transactions: [{
            "amount": {
              "total": arguments['precio'].toString(),
              "currency": "USD",
              "details": {"subtotal": arguments['precio'].toString(), "shipping": '0', "shipping_discount": 0}
            },
            "description": "Compra de material: ${arguments['titulo']} en BookSwap UNIMET",
            "item_list": {
              "items": [{"name": arguments['titulo'] ?? "Libro", "quantity": 1, "price": arguments['precio'].toString(), "currency": "USD"}],
            }
          }],
          note: "Pago procesado por BookSwap.",
          onSuccess: (Map params) async => await _finalizarPedidoEnFirebase(context, arguments),
          onError: (error) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $error'))),
          onCancel: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pago cancelado'))),
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Pago exitoso! Solicitud enviada.')));
      Navigator.pop(context);
    } catch (e) { debugPrint("Error: $e"); }
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String libroId = arguments['id'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('libros').doc(libroId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) return const Center(child: CircularProgressIndicator());
          
          final libroData = snapshot.data!.data() as Map<String, dynamic>;
          libroData['id'] = snapshot.data!.id;

          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(context, libroData['precio'] ?? 0.0, libroData['imagen'] ?? libroData['imageUrl'] ?? '', libroData),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(libroData['titulo'] ?? 'Sin título', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          Text(libroData['autor'] ?? 'Anónimo', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                          const SizedBox(height: 8),
                          _buildStockInfo(libroData),
                          const SizedBox(height: 25),
                          const Text("Estado de la Transacción", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 12),
                          _buildStatusTimeline(),
                          const SizedBox(height: 25),
                          _buildInfoCard("Descripción", libroData['descripcion'] ?? 'Sin descripción'),
                          const SizedBox(height: 25),
                          _buildSellerCard(context, libroData),
                          if (_mostrarPago) ...[
                            const SizedBox(height: 25),
                            _buildPayPalSection(context, libroData),
                          ],
                          const SizedBox(height: 180), 
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _buildBackButton(context),
              if (!_mostrarPago)
                Positioned(bottom: 20, left: 20, right: 20, child: _buildBottomActionArea(context, libroData)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomActionArea(BuildContext context, Map<String, dynamic> libroData) {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final bool isOwner = currentUserId == libroData['userId'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!isOwner) ...[
          _buildWhatsAppButton(libroData),
          const SizedBox(width: 15),
        ],
        SizedBox(
          width: isOwner ? 360 : 360, 
          child: ElevatedButton(
            onPressed: isOwner 
                ? () => _mostrarDialogoEditar(context, libroData)
                : () => _iniciarProcesoDeSolicitud(),
            style: ElevatedButton.styleFrom(
              backgroundColor: isOwner ? Colors.grey[800] : const Color(0xFF1E88E5),
              minimumSize: const Size(0, 60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 4,
            ),
            child: Text(
              isOwner ? "Editar Publicación" : "Solicitar Material",
              style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStockInfo(Map<String, dynamic> data) {
    final int stock = data['stock'] ?? 0;
    return Row(
      children: [
        Icon(Icons.inventory_2_outlined, size: 16, color: stock > 0 ? Colors.green : Colors.red),
        const SizedBox(width: 8),
        Text("Stock: $stock", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: stock > 0 ? Colors.green[700] : Colors.red)),
      ],
    );
  }

  Widget _buildWhatsAppButton(Map<String, dynamic> arguments) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('usuarios').doc(arguments['userId']).snapshots(),
      builder: (context, snapshot) {
        String phone = "";
        if (snapshot.hasData && snapshot.data!.exists) {
          phone = (snapshot.data!.data() as Map<String, dynamic>)['telefono'] ?? "";
        }
        return Container(
          height: 60, width: 60,
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)]),
          child: IconButton(
            onPressed: () async {
              if (phone.isEmpty) return;
              String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
              if (cleanPhone.startsWith('0')) cleanPhone = '58${cleanPhone.substring(1)}';
              final url = "https://wa.me/$cleanPhone?text=Hola, me interesa tu libro '${arguments['titulo']}'";
              if (await canLaunchUrl(Uri.parse(url))) await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
            },
            icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Color(0xFF25D366), size: 30),
          ),
        );
      },
    );
  }

  Widget _buildPayPalSection(BuildContext context, Map<String, dynamic> arguments) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF003087), width: 2)),
      child: Column(
        children: [
          const Text("Checkout Seguro", style: TextStyle(color: Color(0xFF003087), fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 15),
          Text("Total: \$${arguments['precio']}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _ejecutarPagoReal(context, arguments),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFC439), foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 50)),
            child: const Text("Pagar con PayPal", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          TextButton(onPressed: () => setState(() => _mostrarPago = false), child: const Text("Cancelar", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic precio, String rutaImagen, Map<String, dynamic> arguments) {
    return SizedBox(
      height: 320, width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(child: Image.network(rutaImagen, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(color: Colors.grey))),
          Positioned(
            top: 45, right: 20,
            child: Row(
              children: [
                _buildCircularAction(icon: Icons.share_outlined, onPressed: () => Share.share('¡Mira esto en BookSwap!\n${arguments['titulo']}')),
                const SizedBox(width: 12),
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance.collection('usuarios').doc(FirebaseAuth.instance.currentUser?.uid).collection('favoritos').doc(arguments['id']).snapshots(),
                  builder: (context, snapshot) {
                    bool esFav = snapshot.hasData && snapshot.data!.exists;
                    return _buildCircularAction(icon: esFav ? Icons.favorite : Icons.favorite_border, iconColor: esFav ? Colors.red : Colors.black, 
                      onPressed: () => context.read<CoraCubit>().toggleFavorito(arguments['id'], esFav));
                  },
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20, left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(color: const Color(0xFF1E88E5), borderRadius: BorderRadius.circular(12)),
              child: Text("VENTA - \$ $precio", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  Widget _buildBackButton(BuildContext context) {
    return Positioned(top: 45, left: 20, child: CircleAvatar(backgroundColor: Colors.white, child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context))));
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
    return Column(children: [
      Icon(icon, color: active ? const Color(0xFF1E88E5) : Colors.grey, size: 24),
      const SizedBox(height: 6),
      Text(label, style: TextStyle(fontSize: 10, color: active ? Colors.black : Colors.grey)),
    ]);
  }

  Widget _buildInfoCard(String titulo, String contenido) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        Text(contenido, style: const TextStyle(color: Colors.black87, height: 1.5)),
      ]),
    );
  }

  Widget _buildSellerCard(BuildContext context, Map<String, dynamic> arguments) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        CircleAvatar(backgroundColor: const Color(0xFF003870), child: Text(arguments['iniciales'] ?? '?', style: const TextStyle(color: Colors.white))),
        const SizedBox(width: 15),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(arguments['vendedor'] ?? 'Vendedor', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(arguments['carrera'] ?? 'UNIMET', style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ])),
        TextButton(onPressed: () => Navigator.pushNamed(context, '/perfil', arguments: {...arguments, 'isOtherUser': true}), 
          child: const Text("Ver Perfil", style: TextStyle(color: Color(0xFF1E88E5), fontWeight: FontWeight.bold))),
      ]),
    );
  }

  Widget statusItem(String label, IconData icon, bool isActive) {
    return Column(
      children: [
        Icon(icon, color: isActive ? const Color(0xFF1E88E5) : Colors.grey, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.black : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}