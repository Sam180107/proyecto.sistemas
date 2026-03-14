import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/cubits/notification_cubit.dart';

class NotificacionesPage extends StatelessWidget {
  const NotificacionesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        final reports = state.unreadReports;
        final orders = state.pendingOrders;
        final allEmpty = reports.isEmpty && orders.isEmpty;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FB),
          appBar: AppBar(
            title: Text('Notificaciones',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF003870),
            elevation: 1,
          ),
          body: allEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none_rounded,
                          size: 72, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text('No tienes notificaciones nuevas',
                          style: GoogleFonts.inter(
                              fontSize: 16, color: Colors.black54)),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    if (orders.isNotEmpty) ...[
                      _sectionHeader(
                          'Nuevas solicitudes de compra', Icons.shopping_bag_outlined, Colors.blue),
                      const SizedBox(height: 8),
                      ...orders.map((o) => _orderCard(context, o)),
                      const SizedBox(height: 20),
                    ],
                    if (reports.isNotEmpty) ...[
                      _sectionHeader(
                          'Avisos del Administrador', Icons.admin_panel_settings_outlined, Colors.orange),
                      const SizedBox(height: 8),
                      ...reports.map((r) => _reportCard(context, r)),
                    ],
                  ],
                ),
        );
      },
    );
  }

  Widget _sectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(title,
            style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
      ],
    );
  }

  Widget _orderCard(BuildContext context, Map<String, dynamic> order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBBDEFB), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.shopping_bag_outlined,
                color: Color(0xFF1976D2), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nueva solicitud de compra',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  '"${order['bookTitle'] ?? 'Libro'}" — ${order['buyerName'] ?? 'Un comprador'}',
                  style:
                      GoogleFonts.inter(fontSize: 13, color: Colors.black54),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/orders'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF003870),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Ver',
                style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _reportCard(BuildContext context, Map<String, dynamic> report) {
    final fecha = report['fecha'] as Timestamp?;
    final fechaStr = fecha != null
        ? '${fecha.toDate().day}/${fecha.toDate().month}/${fecha.toDate().year}'
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE0B2), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.admin_panel_settings_outlined,
                    color: Colors.orange[700], size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Aviso del Administrador',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    if (fechaStr.isNotEmpty)
                      Text(fechaStr,
                          style: GoogleFonts.inter(
                              fontSize: 11, color: Colors.black38)),
                  ],
                ),
              ),
              TextButton(
                onPressed: () =>
                    context.read<NotificationCubit>().markReportAsRead(report['id']),
                child: Text('Marcar leído',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: Colors.orange[700])),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBF0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.format_quote_rounded,
                    color: Colors.orange[300], size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    report['mensaje'] ?? 'Sin mensaje',
                    style:
                        GoogleFonts.inter(fontSize: 13, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
          if ((report['titulo'] as String?)?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text('Publicación afectada: "${report['titulo']}"',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.black45)),
          ],
        ],
      ),
    );
  }
}
