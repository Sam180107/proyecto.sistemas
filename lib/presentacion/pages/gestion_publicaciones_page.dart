import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/cubits/publication_moderation_cubit.dart';
import '../widgets/custom_app_bar.dart';

class GestionPublicacionesPage extends StatelessWidget {
  const GestionPublicacionesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PublicationModerationCubit(),
      child: const _GestionPublicacionesContent(),
    );
  }
}

class _GestionPublicacionesContent extends StatefulWidget {
  const _GestionPublicacionesContent();

  @override
  State<_GestionPublicacionesContent> createState() =>
      _GestionPublicacionesContentState();
}

class _GestionPublicacionesContentState
    extends State<_GestionPublicacionesContent> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmarEliminar(String docId, String titulo) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 28,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Eliminar Publicación',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: GoogleFonts.inter(fontSize: 15, color: Colors.black87),
            children: [
              const TextSpan(text: '¿Estás seguro de que deseas eliminar '),
              TextSpan(
                text: '"$titulo"',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: '?\n\nEsta acción no se puede deshacer.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<PublicationModerationCubit>().eliminarPublicacion(
                docId,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Eliminar',
              style: GoogleFonts.inter(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmarCongelar(String docId, String titulo, bool isFrozen) {
    context.read<PublicationModerationCubit>().freezePublication(
      docId,
      !isFrozen,
    );
  }

  void _mostrarDialogoReporte(String docId, String userId, String titulo) {
    final msgController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(
              Icons.report_problem_outlined,
              color: Colors.orange,
              size: 28,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Enviar Reporte al Vendedor',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Publicación: "$titulo"',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.black54,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Mensaje para el vendedor:',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: msgController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    'Ej: Tu publicación no cumple con las normas de la plataforma. Por favor actualiza la descripción...',
                hintStyle: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: const Color(0xFFF8F9FB),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              if (msgController.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              print(
                "GestionPublicacionesPage: Reporting book ${docId} to seller ${userId}",
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Enviando reporte a: $userId'),
                  duration: const Duration(seconds: 2),
                ),
              );
              context.read<PublicationModerationCubit>().reportPublication(
                docId: docId,
                userId: userId,
                titulo: titulo,
                mensaje: msgController.text.trim(),
              );
            },
            icon: const Icon(Icons.send, size: 18),
            label: Text(
              'Enviar Reporte',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PublicationModerationCubit, PublicationModerationState>(
      listener: (context, state) {
        if (state is PublicationModerationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        } else if (state is PublicationModerationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
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
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE8EAF0), width: 1),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFF2F4F7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gestión de Publicaciones',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                        Text(
                          'Administra todas las publicaciones de libros en la plataforma',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 300,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Buscar publicación...',
                        hintStyle: GoogleFonts.inter(color: Colors.grey),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF2F4F7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Lista de publicaciones
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('libros').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF003870),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: GoogleFonts.inter(),
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No hay publicaciones registradas',
                        style: GoogleFonts.inter(color: Colors.black54),
                      ),
                    );
                  }

                  final allDocs = snapshot.data!.docs;
                  final filteredDocs = allDocs.where((doc) {
                    if (_searchQuery.isEmpty) return true;
                    final data = doc.data() as Map<String, dynamic>;
                    final q = _searchQuery.toLowerCase();
                    return (data['titulo'] as String? ?? '')
                            .toLowerCase()
                            .contains(q) ||
                        (data['autor'] as String? ?? '').toLowerCase().contains(
                          q,
                        ) ||
                        (data['materia'] as String? ?? '')
                            .toLowerCase()
                            .contains(q);
                  }).toList();

                  filteredDocs.sort((a, b) {
                    final dA =
                        (a.data() as Map<String, dynamic>)['fechaCreacion']
                            as Timestamp?;
                    final dB =
                        (b.data() as Map<String, dynamic>)['fechaCreacion']
                            as Timestamp?;
                    if (dA == null && dB == null) return 0;
                    if (dA == null) return 1;
                    if (dB == null) return -1;
                    return dB.compareTo(dA);
                  });

                  if (filteredDocs.isEmpty) {
                    return Center(
                      child: Text(
                        'No se encontraron resultados para "$_searchQuery"',
                        style: GoogleFonts.inter(color: Colors.black54),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final doc = filteredDocs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      return _buildPublicacionCard(doc.id, data);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPublicacionCard(String docId, Map<String, dynamic> data) {
    final tipo = data['tipoTransaccion'] ?? data['tipo'] ?? 'Venta';
    final imageUrl = data['imageUrl'] as String?;
    final estado = data['estado'] as String? ?? 'Disponible';
    final isFrozen = estado == 'Congelado';
    final userId = data['userId'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isFrozen ? const Color(0xFFEEF2FF) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isFrozen
            ? Border.all(color: const Color(0xFF5C6BC0), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 70,
              height: 90,
              color: Colors.grey[100],
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.book, size: 32, color: Colors.grey),
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.book, size: 32, color: Colors.grey),
                    ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        data['titulo'] ?? 'Sin título',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: const Color(0xFF1A1A1A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isFrozen) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5C6BC0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'CONGELADO',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Autor: ${data['autor'] ?? 'N/A'}',
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 2),
                Text(
                  'Materia: ${data['materia'] ?? 'N/A'} • Vendedor: ${data['vendedor'] ?? 'N/A'}',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.black45),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: tipo == 'Intercambio'
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              tipo,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: tipo == 'Intercambio'
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFF1976D2),
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (tipo != 'Intercambio')
            Text(
              '\$ ${data['precio'] ?? '0.00'}',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: const Color(0xFF1976D2),
              ),
            ),
          const SizedBox(width: 12),
          // Botón Congelar / Descongelar
          IconButton(
            onPressed: () =>
                _confirmarCongelar(docId, data['titulo'] ?? '', isFrozen),
            icon: Icon(
              isFrozen ? Icons.lock_open_rounded : Icons.ac_unit_rounded,
            ),
            style: IconButton.styleFrom(
              backgroundColor: isFrozen
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFE8EAF6),
              foregroundColor: isFrozen
                  ? Colors.green[700]
                  : const Color(0xFF5C6BC0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
            ),
            tooltip: isFrozen
                ? 'Descongelar publicación'
                : 'Congelar publicación',
          ),
          const SizedBox(width: 8),
          // Botón Reportar
          IconButton(
            onPressed: () =>
                _mostrarDialogoReporte(docId, userId, data['titulo'] ?? ''),
            icon: const Icon(Icons.report_problem_outlined),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFFFF3E0),
              foregroundColor: Colors.orange[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
            ),
            tooltip: 'Reportar al vendedor',
          ),
          const SizedBox(width: 8),
          // Botón Eliminar
          IconButton(
            onPressed: () =>
                _confirmarEliminar(docId, data['titulo'] ?? 'Sin título'),
            icon: const Icon(Icons.delete_outline),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFFBE9E7),
              foregroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
            ),
            tooltip: 'Eliminar publicación',
          ),
        ],
      ),
    );
  }
}
