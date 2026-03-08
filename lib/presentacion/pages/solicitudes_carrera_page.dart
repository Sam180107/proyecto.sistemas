import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/custom_app_bar.dart';

class SolicitudesCarreraPage extends StatefulWidget {
  const SolicitudesCarreraPage({super.key});

  @override
  State<SolicitudesCarreraPage> createState() => _SolicitudesCarreraPageState();
}

class _SolicitudesCarreraPageState extends State<SolicitudesCarreraPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _filtroEstado = 'Todos';

  Future<void> _aprobarSolicitud(String docId, Map<String, dynamic> data) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.green, size: 28),
            const SizedBox(width: 8),
            Text('Aprobar Solicitud', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: GoogleFonts.inter(fontSize: 15, color: Colors.black87),
            children: [
              const TextSpan(text: '¿Aprobar el cambio de carrera de '),
              TextSpan(
                text: '"${data['correo'] ?? 'usuario'}"',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: ' de "${data['carrera_actual'] ?? 'N/A'}" a "${data['nueva_carrera'] ?? 'N/A'}"?'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar', style: GoogleFonts.inter(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Aprobar', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      try {
        // Actualizar estado de solicitud
        await _firestore.collection('solicitudes_carrera').doc(docId).update({
          'estado': 'Aprobada',
          'fecha_respuesta': FieldValue.serverTimestamp(),
        });

        // Actualizar carrera del usuario
        if (data['uid'] != null) {
          await _firestore.collection('usuarios').doc(data['uid']).update({
            'carrera': data['nueva_carrera'],
          });
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Solicitud aprobada y carrera actualizada.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  Future<void> _rechazarSolicitud(String docId, Map<String, dynamic> data) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.cancel_outlined, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            Text('Rechazar Solicitud', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          '¿Rechazar la solicitud de cambio de carrera de "${data['correo'] ?? 'usuario'}"?',
          style: GoogleFonts.inter(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar', style: GoogleFonts.inter(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Rechazar', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      try {
        await _firestore.collection('solicitudes_carrera').doc(docId).update({
          'estado': 'Rechazada',
          'fecha_respuesta': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Solicitud rechazada.'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 28),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFE8EAF0), width: 1)),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFF2F4F7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Solicitudes de Cambio de Carrera',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      Text(
                        'Gestiona las solicitudes de cambio de carrera de los estudiantes',
                        style: GoogleFonts.inter(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                // Filtro por estado
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F7),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _filtroEstado,
                      items: ['Todos', 'Pendiente', 'Aprobada', 'Rechazada']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.inter(fontSize: 14))))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _filtroEstado = val);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Lista de solicitudes
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('solicitudes_carrera')
                  .orderBy('fecha_solicitud', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF003870)));
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No hay solicitudes de cambio de carrera',
                          style: GoogleFonts.inter(fontSize: 16, color: Colors.black54),
                        ),
                      ],
                    ),
                  );
                }

                final docs = snapshot.data!.docs.where((doc) {
                  if (_filtroEstado == 'Todos') return true;
                  final data = doc.data() as Map<String, dynamic>;
                  return data['estado'] == _filtroEstado;
                }).toList();

                if (docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No hay solicitudes con estado "$_filtroEstado"',
                      style: GoogleFonts.inter(fontSize: 15, color: Colors.black54),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return _buildSolicitudCard(doc.id, data);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSolicitudCard(String docId, Map<String, dynamic> data) {
    final estado = data['estado'] ?? 'Pendiente';
    final correo = data['correo'] ?? 'Sin correo';
    final carreraActual = data['carrera_actual'] ?? 'N/A';
    final nuevaCarrera = data['nueva_carrera'] ?? 'N/A';
    final fecha = data['fecha_solicitud'] as Timestamp?;
    final fechaStr = fecha != null
        ? '${fecha.toDate().day}/${fecha.toDate().month}/${fecha.toDate().year}'
        : 'Sin fecha';

    Color estadoColor;
    Color estadoBgColor;
    IconData estadoIcon;
    switch (estado) {
      case 'Aprobada':
        estadoColor = Colors.green;
        estadoBgColor = const Color(0xFFE8F5E9);
        estadoIcon = Icons.check_circle;
        break;
      case 'Rechazada':
        estadoColor = Colors.red;
        estadoBgColor = const Color(0xFFFBE9E7);
        estadoIcon = Icons.cancel;
        break;
      default:
        estadoColor = Colors.orange;
        estadoBgColor = const Color(0xFFFFF3E0);
        estadoIcon = Icons.pending;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          // Icono de estado
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: estadoBgColor, borderRadius: BorderRadius.circular(14)),
            child: Icon(estadoIcon, color: estadoColor, size: 28),
          ),
          const SizedBox(width: 20),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(correo, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(carreraActual, style: GoogleFonts.inter(fontSize: 13, color: Colors.black54)),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 16, color: Color(0xFF1976D2)),
                    const SizedBox(width: 8),
                    Text(nuevaCarrera, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1976D2))),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Fecha: $fechaStr', style: GoogleFonts.inter(fontSize: 12, color: Colors.black38)),
              ],
            ),
          ),
          // Badge estado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: estadoBgColor, borderRadius: BorderRadius.circular(10)),
            child: Text(
              estado,
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: estadoColor),
            ),
          ),
          // Botones de acción (solo si está pendiente)
          if (estado == 'Pendiente') ...[
            const SizedBox(width: 12),
            IconButton(
              onPressed: () => _aprobarSolicitud(docId, data),
              icon: const Icon(Icons.check_circle_outline),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFE8F5E9),
                foregroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.all(12),
              ),
              tooltip: 'Aprobar',
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _rechazarSolicitud(docId, data),
              icon: const Icon(Icons.cancel_outlined),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFFBE9E7),
                foregroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.all(12),
              ),
              tooltip: 'Rechazar',
            ),
          ],
        ],
      ),
    );
  }
}
