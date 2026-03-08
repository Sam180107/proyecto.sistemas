import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/custom_app_bar.dart';

class GestionPublicacionesPage extends StatefulWidget {
  const GestionPublicacionesPage({super.key});

  @override
  State<GestionPublicacionesPage> createState() =>
      _GestionPublicacionesPageState();
}

class _GestionPublicacionesPageState extends State<GestionPublicacionesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _eliminarPublicacion(String docId, String titulo) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
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

    if (confirmado == true) {
      try {
        await _firestore.collection('libros').doc(docId).delete();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Publicación "$titulo" eliminada exitosamente.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
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
                // Barra de búsqueda
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Buscar publicación...',
                      hintStyle: GoogleFonts.inter(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
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
                    child: CircularProgressIndicator(color: Color(0xFF003870)),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar publicaciones',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${snapshot.error}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.library_books_outlined,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay publicaciones registradas',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                final allDocs = snapshot.data!.docs;
                // Filtrar por búsqueda
                final filteredDocs = allDocs.where((doc) {
                  if (_searchQuery.isEmpty) return true;
                  final data = doc.data() as Map<String, dynamic>;
                  final titulo = (data['titulo'] as String? ?? '')
                      .toLowerCase();
                  final autor = (data['autor'] as String? ?? '').toLowerCase();
                  final materia = (data['materia'] as String? ?? '')
                      .toLowerCase();
                  final query = _searchQuery.toLowerCase();
                  return titulo.contains(query) ||
                      autor.contains(query) ||
                      materia.contains(query);
                }).toList();
                filteredDocs.sort((a, b) {
                  final dataA = a.data() as Map<String, dynamic>;
                  final dataB = b.data() as Map<String, dynamic>;
                  final dateA = dataA['fechaCreacion'] as Timestamp?;
                  final dateB = dataB['fechaCreacion'] as Timestamp?;
                  if (dateA == null && dateB == null) return 0;
                  if (dateA == null) return 1;
                  if (dateB == null) return -1;
                  return dateB.compareTo(dateA);
                });
                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron resultados para "$_searchQuery"',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: Colors.black54,
                          ),
                        ),
                      ],
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
    );
  }

  Widget _buildPublicacionCard(String docId, Map<String, dynamic> data) {
    final tipo = data['tipoTransaccion'] ?? data['tipo'] ?? 'Venta';
    final imageUrl = data['imageUrl'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                            child: Icon(
                              Icons.book,
                              size: 32,
                              color: Colors.grey,
                            ),
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
                Text(
                  data['titulo'] ?? 'Sin título',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: const Color(0xFF1A1A1A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
          const SizedBox(width: 20),
          IconButton(
            onPressed: () =>
                _eliminarPublicacion(docId, data['titulo'] ?? 'Sin título'),
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
