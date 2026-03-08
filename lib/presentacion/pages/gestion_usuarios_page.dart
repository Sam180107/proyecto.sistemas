import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/custom_app_bar.dart';
import 'detalle_usuario_page.dart';

class GestionUsuariosPage extends StatefulWidget {
  const GestionUsuariosPage({super.key});

  @override
  State<GestionUsuariosPage> createState() => _GestionUsuariosPageState();
}

class _GestionUsuariosPageState extends State<GestionUsuariosPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _editarUsuario(String uid, Map<String, dynamic> data) async {
    final nombreController = TextEditingController(text: data['nombre'] ?? '');
    final telefonoController = TextEditingController(
      text: data['telefono'] ?? '',
    );
    final carreraController = TextEditingController(
      text: data['carrera'] ?? data['departamento'] ?? '',
    );
    String rol = data['rol'] ?? 'Estudiante';

    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Editar Usuario',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 450,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: nombreController,
                        label: 'Nombre Completo',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: telefonoController,
                        label: 'Teléfono',
                        icon: Icons.phone_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: carreraController,
                        label: rol == 'Profesor' ? 'Departamento' : 'Carrera',
                        icon: Icons.school_outlined,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: rol,
                        decoration: InputDecoration(
                          labelText: 'Rol',
                          prefixIcon: const Icon(
                            Icons.badge_outlined,
                            color: Colors.grey,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8F9FB),
                        ),
                        items: ['Estudiante', 'Profesor', 'Admin']
                            .map(
                              (r) => DropdownMenuItem(value: r, child: Text(r)),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => rol = val);
                          }
                        },
                      ),
                    ],
                  ),
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
                    backgroundColor: const Color(0xFF003870),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                  ),
                  child: Text(
                    'Guardar Cambios',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (resultado == true) {
      try {
        Map<String, dynamic> updateData = {
          'nombre': nombreController.text.trim(),
          'telefono': telefonoController.text.trim(),
          'rol': rol,
        };

        if (rol == 'Profesor') {
          updateData['departamento'] = carreraController.text.trim();
        } else {
          updateData['carrera'] = carreraController.text.trim();
        }

        await _firestore.collection('usuarios').doc(uid).update(updateData);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Usuario "${nombreController.text.trim()}" actualizado exitosamente.',
            ),
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
            content: Text('Error al actualizar: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }

    nombreController.dispose();
    telefonoController.dispose();
    carreraController.dispose();
  }

  Future<void> _eliminarUsuario(String uid, String nombre) async {
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
                'Eliminar Usuario',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: GoogleFonts.inter(fontSize: 15, color: Colors.black87),
            children: [
              const TextSpan(
                text: '¿Estás seguro de que deseas eliminar al usuario ',
              ),
              TextSpan(
                text: '"$nombre"',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                text:
                    '?\n\nSe eliminará su perfil de la base de datos. Esta acción no se puede deshacer.',
              ),
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
        await _firestore.collection('usuarios').doc(uid).delete();
        final librosSnapshot = await _firestore
            .collection('libros')
            .where('userId', isEqualTo: uid)
            .get();
        for (final doc in librosSnapshot.docs) {
          await doc.reference.delete();
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Usuario "$nombre" y sus publicaciones fueron eliminados.',
            ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF003870), width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFFF8F9FB),
      ),
    );
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
                        'Gestión de Usuarios',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      StreamBuilder<List<QuerySnapshot>>(
                        stream: Stream.fromFuture(
                          Future.wait([
                            _firestore.collection('usuarios').get(),
                            _firestore.collection('users').get(),
                          ]),
                        ),
                        builder: (context, snapshot) {
                          int total = 0;
                          if (snapshot.hasData) {
                            for (var snap in snapshot.data!) {
                              total += snap.docs.length;
                            }
                          }
                          return Text(
                            'Administra los $total usuarios registrados en la plataforma',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          );
                        },
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
                      hintText: 'Buscar usuario...',
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
          // Lista de usuarios
          Expanded(
            child: StreamBuilder<List<QuerySnapshot>>(
              stream: Stream.fromFuture(
                Future.wait([
                  _firestore.collection('usuarios').get(),
                  _firestore.collection('users').get(),
                ]),
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF003870)),
                  );
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final allDocs = <QueryDocumentSnapshot>[];
                if (snapshot.hasData) {
                  for (var snap in snapshot.data!) {
                    allDocs.addAll(snap.docs);
                  }
                }

                if (allDocs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        const Text('No hay usuarios registrados'),
                      ],
                    ),
                  );
                }

                final docs = allDocs.where((doc) {
                  if (_searchQuery.isEmpty) return true;
                  final data = doc.data() as Map<String, dynamic>;
                  final nombre = (data['nombre'] as String? ?? '')
                      .toLowerCase();
                  final correo = (data['correo'] as String? ?? '')
                      .toLowerCase();
                  final rol = (data['rol'] as String? ?? '').toLowerCase();
                  final carrera =
                      (data['carrera'] as String? ??
                              data['departamento'] as String? ??
                              '')
                          .toLowerCase();
                  final query = _searchQuery.toLowerCase();
                  return nombre.contains(query) ||
                      correo.contains(query) ||
                      rol.contains(query) ||
                      carrera.contains(query);
                }).toList();

                if (docs.isEmpty) {
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
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return _buildUsuarioCard(doc.id, data);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsuarioCard(String uid, Map<String, dynamic> data) {
    final nombre = data['nombre'] ?? 'Sin nombre';
    final correo = data['correo'] ?? 'Sin correo';
    final rol = data['rol'] ?? 'Estudiante';
    final telefono = data['telefono'] ?? 'N/A';
    final carrera = data['carrera'] ?? data['departamento'] ?? 'N/A';
    final iniciales = nombre.isNotEmpty
        ? nombre
              .split(' ')
              .take(2)
              .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
              .join()
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
          // Avatar
          CircleAvatar(
            radius: 26,
            backgroundColor: rolBgColor,
            child: Text(
              iniciales,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: rolColor,
              ),
            ),
          ),
          const SizedBox(width: 20),
          // Info del usuario
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        correo,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      telefono,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.school_outlined,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        carrera,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.black45,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Badge de rol
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: rolBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              rol,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: rolColor,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Botón ver perfil
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DetalleUsuarioPage(uid: uid, userData: data),
                ),
              );
            },
            icon: const Icon(Icons.visibility_outlined),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF3E5F5),
              foregroundColor: const Color(0xFF6A1B9A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
            ),
            tooltip: 'Ver perfil y publicaciones',
          ),
          const SizedBox(width: 8),
          // Botón editar
          IconButton(
            onPressed: () => _editarUsuario(uid, data),
            icon: const Icon(Icons.edit_outlined),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFE3F2FD),
              foregroundColor: const Color(0xFF1976D2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
            ),
            tooltip: 'Editar usuario',
          ),
          const SizedBox(width: 8),
          // Botón eliminar
          IconButton(
            onPressed: () => _eliminarUsuario(uid, nombre),
            icon: const Icon(Icons.delete_outline),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFFBE9E7),
              foregroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
            ),
            tooltip: 'Eliminar usuario',
          ),
        ],
      ),
    );
  }
}
