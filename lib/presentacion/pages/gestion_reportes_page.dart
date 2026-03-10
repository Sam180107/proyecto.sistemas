import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/custom_app_bar.dart';

class GestionReportesPage extends StatefulWidget {
  const GestionReportesPage({super.key});

  @override
  State<GestionReportesPage> createState() => _GestionReportesPageState();
}

class _GestionReportesPageState extends State<GestionReportesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _filtroEstado = 'Todos';

  Future<void> _resolverReporte(String docId, Map<String, dynamic> data) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.green, size: 28),
            const SizedBox(width: 8),
            Text('Resolver Reporte', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          '¿Marcar este reporte como resuelto?\n\nMotivo original: "${data['motivo'] ?? 'Sin motivo'}"',
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
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Resolver', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      try {
        await _firestore.collection('reportes').doc(docId).update({
          'estado': 'Resuelto',
          'fecha_resolucion': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Reporte marcado como resuelto.'),
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

  Future<void> _descartarReporte(String docId) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.delete_outline, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            Text('Descartar Reporte', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          '¿Descartar este reporte? Se marcará como descartado.',
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
            child: Text('Descartar', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      try {
        await _firestore.collection('reportes').doc(docId).update({
          'estado': 'Descartado',
          'fecha_resolucion': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Reporte descartado.'),
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

  Future<void> _congelarPublicacion(String docId, Map<String, dynamic> data) async {
    final referenciaId = data['referencia_id'] as String?;
    
    if (referenciaId == null || referenciaId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El reporte no tiene un ID de referencia válido para congelar.')),
      );
      return;
    }

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.ac_unit, color: Colors.blue, size: 28),
            const SizedBox(width: 8),
            Text('Congelar Publicación', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          '¿Estás seguro de congelar esta publicación? Se ocultará para todos los usuarios.',
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
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Congelar', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      try {
        // Congelar la publicacion
        await _firestore.collection('libros').doc(referenciaId).update({
          'estado': 'Congelado',
        });

        // Notificar al usuario (FORCE EDIT)
        final targetUserId = data['creador_elemento_id'] as String?;
        if (targetUserId != null && targetUserId.isNotEmpty) {
          await _firestore.collection('notificaciones').add({
            'targetUserId': targetUserId,
            'titulo': 'Publicación Congelada',
            'mensaje': 'Tu publicación "${data['elemento_reportado']}" ha sido congelada por un administrador. Debes editarla para reactivarla.',
            'fecha': FieldValue.serverTimestamp(),
            'leido': false,
            'tipo': 'admin_report',
          });
        }

        // Marcar reporte como resuelto
        await _firestore.collection('reportes').doc(docId).update({
          'estado': 'Resuelto',
          'fecha_resolucion': FieldValue.serverTimestamp(),
          'accion_tomada': 'Publicación Congelada',
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Publicación congelada correctamente.'),
            backgroundColor: Colors.blue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al congelar: $e'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
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
                        'Gestión de Reportes',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      Text(
                        'Revisa y gestiona los reportes y denuncias de la comunidad',
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
                      items: ['Todos', 'Pendiente', 'Resuelto', 'Descartado']
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
          // Lista de reportes
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('reportes').snapshots(),
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
                        Icon(Icons.flag_outlined, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No hay reportes registrados',
                          style: GoogleFonts.inter(fontSize: 16, color: Colors.black54),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Cuando los usuarios envíen reportes, aparecerán aquí',
                          style: GoogleFonts.inter(fontSize: 13, color: Colors.black38),
                        ),
                      ],
                    ),
                  );
                }

                final allDocs = snapshot.data!.docs.toList();
                // Ordenar por fecha en memoria
                allDocs.sort((a, b) {
                  final dataA = a.data() as Map<String, dynamic>;
                  final dataB = b.data() as Map<String, dynamic>;
                  final dateA = dataA['fecha_reporte'] as Timestamp?;
                  final dateB = dataB['fecha_reporte'] as Timestamp?;
                  if (dateA == null && dateB == null) return 0;
                  if (dateA == null) return 1;
                  if (dateB == null) return -1;
                  return dateB.compareTo(dateA);
                });

                final docs = allDocs.where((doc) {
                  if (_filtroEstado == 'Todos') return true;
                  final data = doc.data() as Map<String, dynamic>;
                  return data['estado'] == _filtroEstado;
                }).toList();

                if (docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No hay reportes con estado "$_filtroEstado"',
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
                    return _buildReporteCard(doc.id, data);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReporteCard(String docId, Map<String, dynamic> data) {
    final estado = data['estado'] ?? 'Pendiente';
    final motivo = data['motivo'] ?? 'Sin motivo especificado';
    final tipo = data['tipo'] ?? 'General';
    final reportadoPor = data['reportado_por'] ?? 'Anónimo';
    final elementoReportado = data['elemento_reportado'] ?? 'N/A';
    final fecha = data['fecha_reporte'] as Timestamp?;
    final fechaStr = fecha != null
        ? '${fecha.toDate().day}/${fecha.toDate().month}/${fecha.toDate().year}'
        : 'Sin fecha';

    Color estadoColor;
    Color estadoBgColor;
    IconData estadoIcon;
    switch (estado) {
      case 'Resuelto':
        estadoColor = Colors.green;
        estadoBgColor = const Color(0xFFE8F5E9);
        estadoIcon = Icons.check_circle;
        break;
      case 'Descartado':
        estadoColor = Colors.grey;
        estadoBgColor = const Color(0xFFF5F5F5);
        estadoIcon = Icons.remove_circle;
        break;
      default:
        estadoColor = Colors.red;
        estadoBgColor = const Color(0xFFFBE9E7);
        estadoIcon = Icons.flag;
    }

    Color tipoColor;
    switch (tipo.toLowerCase()) {
      case 'usuario':
        tipoColor = const Color(0xFF6A1B9A);
        break;
      case 'publicacion':
      case 'publicación':
        tipoColor = const Color(0xFF1976D2);
        break;
      default:
        tipoColor = Colors.orange;
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: tipoColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(tipo, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: tipoColor)),
                    ),
                    const SizedBox(width: 8),
                    Text('• $fechaStr', style: GoogleFonts.inter(fontSize: 12, color: Colors.black38)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(motivo, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 6),
                Text('Reportado por: $reportadoPor', style: GoogleFonts.inter(fontSize: 13, color: Colors.black54)),
                Text('Elemento: $elementoReportado', style: GoogleFonts.inter(fontSize: 13, color: Colors.black54)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Badge estado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: estadoBgColor, borderRadius: BorderRadius.circular(10)),
            child: Text(
              estado,
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: estadoColor),
            ),
          ),
          // Botones
          if (estado == 'Pendiente') ...[
            const SizedBox(width: 12),
            if (tipo.toLowerCase() == 'publicacion' || tipo.toLowerCase() == 'publicación')
              IconButton(
                onPressed: () => _congelarPublicacion(docId, data),
                icon: const Icon(Icons.ac_unit),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFE3F2FD),
                  foregroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.all(12),
                ),
                tooltip: 'Congelar Publicación',
              ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _resolverReporte(docId, data),
              icon: const Icon(Icons.check_circle_outline),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFE8F5E9),
                foregroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.all(12),
              ),
              tooltip: 'Resolver (Sin acción)',
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _descartarReporte(docId),
              icon: const Icon(Icons.delete_outline),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFFBE9E7),
                foregroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.all(12),
              ),
              tooltip: 'Descartar',
            ),
          ],
        ],
      ),
    );
  }
}
