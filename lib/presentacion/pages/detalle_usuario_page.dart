import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/custom_app_bar.dart';

class DetalleUsuarioPage extends StatelessWidget {
  final String uid;
  final Map<String, dynamic> userData;

  const DetalleUsuarioPage({super.key, required this.uid, required this.userData});

  @override
  Widget build(BuildContext context) {
    final nombre = userData['nombre'] ?? 'Sin nombre';
    final correo = userData['correo'] ?? 'Sin correo';
    final rol = userData['rol'] ?? 'Estudiante';
    final telefono = userData['telefono'] ?? 'N/A';
    final carrera = userData['carrera'] ?? userData['departamento'] ?? 'N/A';
    final iniciales = nombre.isNotEmpty
        ? nombre.split(' ').take(2).map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').join()
        : 'UN';

    Color rolColor;
    Color rolBgColor;
    switch (rol) {
      case 'Admin':
        rolColor = const Color(0xFFD84315);
        rolBgColor = const Color(0xFFFBE9E7);
        break;
      case 'Profesor':
        rolColor = const Color(0xFF6A1B9A);
        rolBgColor = const Color(0xFFF3E5F5);
        break;
      default:
        rolColor = const Color(0xFF1976D2);
        rolBgColor = const Color(0xFFE3F2FD);
    }

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
                Text(
                  'Perfil del Usuario',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
              child: Column(
                children: [
                  // Profile card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Avatar grande
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: rolColor.withOpacity(0.3), width: 3),
                          ),
                          child: CircleAvatar(
                            radius: 45,
                            backgroundColor: rolBgColor,
                            child: Text(
                              iniciales,
                              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 28, color: rolColor),
                            ),
                          ),
                        ),
                        const SizedBox(width: 32),
                        // Info del usuario
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(nombre, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(color: rolBgColor, borderRadius: BorderRadius.circular(8)),
                                    child: Text(rol, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: rolColor)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _infoChip(Icons.email_outlined, correo),
                                  const SizedBox(width: 24),
                                  _infoChip(Icons.phone_outlined, telefono),
                                  const SizedBox(width: 24),
                                  _infoChip(Icons.school_outlined, carrera),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Publicaciones del usuario
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Publicaciones del Usuario',
                          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A1A)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Todos los libros publicados por este usuario',
                          style: GoogleFonts.inter(fontSize: 14, color: Colors.black45),
                        ),
                        const SizedBox(height: 24),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('libros')
                              .where('userId', isEqualTo: uid)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(40),
                                  child: CircularProgressIndicator(color: Color(0xFF003870)),
                                ),
                              );
                            }

                            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(40),
                                  child: Column(
                                    children: [
                                      Icon(Icons.library_books_outlined, size: 48, color: Colors.grey[300]),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Este usuario no tiene publicaciones',
                                        style: GoogleFonts.inter(fontSize: 15, color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            final docs = snapshot.data!.docs;
                            return Column(
                              children: [
                                // Counter
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE3F2FD),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${docs.length} publicación${docs.length != 1 ? 'es' : ''} encontrada${docs.length != 1 ? 's' : ''}',
                                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1976D2)),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Grid de publicaciones
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    int crossAxisCount = constraints.maxWidth > 800 ? 3 : (constraints.maxWidth > 500 ? 2 : 1);
                                    return GridView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossAxisCount,
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                        childAspectRatio: 0.75,
                                      ),
                                      itemCount: docs.length,
                                      itemBuilder: (context, index) {
                                        final data = docs[index].data() as Map<String, dynamic>;
                                        return _buildBookCard(context, data, docs[index].id);
                                      },
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 6),
        Flexible(
          child: Text(text, style: GoogleFonts.inter(fontSize: 14, color: Colors.black54), overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _buildBookCard(BuildContext context, Map<String, dynamic> data, String docId) {
    final titulo = data['titulo'] ?? 'Sin título';
    final autor = data['autor'] ?? 'Sin autor';
    final tipo = data['tipoTransaccion'] ?? data['tipo'] ?? 'Venta';
    final imageUrl = data['imageUrl'] as String?;
    final materia = data['materia'] ?? 'N/A';
    final precio = data['precio'];
    final nombre = userData['nombre'] ?? 'Sin nombre';
    final carrera = userData['carrera'] ?? userData['departamento'] ?? 'N/A';
    final iniciales = nombre.isNotEmpty
        ? nombre.split(' ').take(2).map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').join()
        : 'UN';

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/detalle_libro',
          arguments: {
            'titulo': titulo,
            'autor': autor,
            'descripcion': data['descripcion'] ?? 'Sin descripción',
            'precio': precio ?? '0.00',
            'imagen': imageUrl ?? '',
            'vendedor': nombre,
            'carrera': carrera,
            'userId': uid,
            'iniciales': iniciales,
            'rol': userData['rol'] ?? 'Estudiante',
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8EAF0), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, st) => Center(
                            child: Icon(Icons.book, size: 40, color: Colors.grey[400]),
                          ),
                        )
                      : Center(child: Icon(Icons.book, size: 40, color: Colors.grey[400])),
                ),
              ),
            ),
            // Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      autor,
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      materia,
                      style: GoogleFonts.inter(fontSize: 11, color: Colors.black38),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: tipo == 'Intercambio' ? const Color(0xFFE8F5E9) : const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tipo,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: tipo == 'Intercambio' ? const Color(0xFF2E7D32) : const Color(0xFF1976D2),
                            ),
                          ),
                        ),
                        if (tipo != 'Intercambio' && precio != null)
                          Text(
                            '\$ $precio',
                            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF1976D2)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
