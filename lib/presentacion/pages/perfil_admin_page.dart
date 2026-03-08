import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unimet_marketplace/domain/cubits/profile_cubit.dart';
import '../widgets/custom_app_bar.dart';

class PerfilAdminPage extends StatefulWidget {
  const PerfilAdminPage({super.key});

  @override
  State<PerfilAdminPage> createState() => _PerfilAdminPageState();
}

class _PerfilAdminPageState extends State<PerfilAdminPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _totalSolicitudes = 0;
  int _totalReportes = 0;
  int _totalLibrosPendientes = 0;
  bool _isLoadingMetrics = true;

  @override
  void initState() {
    super.initState();
    _fetchMetrics();
  }

  Future<void> _fetchMetrics() async {
    try {
      final solicitudesSnapshot = await _firestore
          .collection('solicitudes_carrera')
          .where('estado', isEqualTo: 'Pendiente')
          .get();
      final reportesSnapshot = await _firestore
          .collection('reportes')
          .where('estado', isEqualTo: 'Pendiente')
          .get();
      final librosSnapshot = await _firestore.collection('libros').get();

      if (!mounted) return;
      setState(() {
        _totalSolicitudes = solicitudesSnapshot.docs.length;
        _totalReportes = reportesSnapshot.docs.length;
        _totalLibrosPendientes = librosSnapshot.docs.length;
        _isLoadingMetrics = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingMetrics = false;
      });
      debugPrint('Error al obtener métricas: $e');
    }
  }

  void _mostrarDialogoCerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout, color: Colors.orange),
            ),
            const SizedBox(width: 12),
            Text(
              "Cerrar Sesión",
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          "¿Estás seguro de que quieres salir del panel administrativo?",
          style: GoogleFonts.inter(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              "Cancelar",
              style: GoogleFonts.inter(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await context.read<ProfileCubit>().cerrarSesion();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            child: Text(
              "Salir",
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoCambiarNombre(BuildContext context, String nombreActual) {
    final TextEditingController nombreController = TextEditingController(
      text: nombreActual,
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.edit_outlined, color: Color(0xFF1976D2)),
            ),
            const SizedBox(width: 12),
            Text(
              "Cambiar Nombre",
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: TextField(
          controller: nombreController,
          decoration: InputDecoration(
            labelText: "Nuevo Nombre",
            prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF003870), width: 2),
            ),
            filled: true,
            fillColor: const Color(0xFFF8F9FB),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              "Cancelar",
              style: GoogleFonts.inter(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF003870),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            onPressed: () {
              final nuevoNombre = nombreController.text.trim();
              if (nuevoNombre.isNotEmpty && nuevoNombre != nombreActual) {
                context.read<ProfileCubit>().actualizarNombre(nuevoNombre);
              }
              Navigator.pop(dialogContext);
            },
            child: Text(
              "Guardar",
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: const CustomAppBar(),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          Map<String, dynamic> userData = {};
          if (state is ProfileLoaded) {
            userData = state.userData;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "PANEL ADMINISTRATIVO",
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Gestión de seguridad y métricas del sistema",
                  style: GoogleFonts.inter(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 32),
                LayoutBuilder(
                  builder: (context, constraints) {
                    bool isDesktop = constraints.maxWidth > 900;
                    return isDesktop
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: _buildAdminSidebar(context, userData),
                              ),
                              const SizedBox(width: 32),
                              Expanded(
                                flex: 2,
                                child: _buildAdminMainContent(
                                  context,
                                  userData,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              _buildAdminSidebar(context, userData),
                              const SizedBox(height: 32),
                              _buildAdminMainContent(context, userData),
                            ],
                          );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdminSidebar(BuildContext context, Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF003870).withOpacity(0.2),
                width: 3,
              ),
            ),
            child: const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF003870),
              child: Icon(
                Icons.admin_panel_settings,
                color: Colors.white,
                size: 50,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            data['nombre'] ?? "Administrador",
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFBE9E7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "Rol: ${data['rol'] ?? 'Admin Sistema'}",
              style: GoogleFonts.inter(
                color: const Color(0xFFD84315),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          _infoRow(
            Icons.email_outlined,
            data['correo'] ?? "admin@unimet.edu.ve",
          ),
          const SizedBox(height: 12),
          _infoRow(Icons.phone_android, data['telefono'] ?? "N/A"),
        ],
      ),
    );
  }

  Widget _buildAdminMainContent(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    return Column(
      children: [
        Row(
          children: [
            _adminStatCard(
              _isLoadingMetrics ? '...' : _totalSolicitudes.toString(),
              "PETICIONES",
              "Cambios de Carrera",
              Colors.orange,
              Icons.assignment_ind_outlined,
            ),
            const SizedBox(width: 16),
            _adminStatCard(
              _isLoadingMetrics ? '...' : _totalReportes.toString(),
              "REPORTES",
              "Denuncias Pendientes",
              Colors.redAccent,
              Icons.flag_outlined,
            ),
            const SizedBox(width: 16),
            _adminStatCard(
              _isLoadingMetrics ? '...' : _totalLibrosPendientes.toString(),
              "PUBLICACIONES",
              "Libros Totales",
              const Color(0xFF1976D2),
              Icons.menu_book_outlined,
            ),
          ],
        ),
        const SizedBox(height: 28),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _adminListTile(
                Icons.edit_outlined,
                "Cambiar Nombre",
                subtitle: "Actualiza tu nombre de administrador",
                color: const Color(0xFF1976D2),
                onTap: () =>
                    _mostrarDialogoCambiarNombre(context, data['nombre'] ?? ""),
              ),
              const Divider(height: 1, indent: 20, endIndent: 20),
              _adminListTile(
                Icons.logout,
                "Cerrar Sesión",
                subtitle: "Salir del panel administrativo",
                color: Colors.orange,
                onTap: () => _mostrarDialogoCerrarSesion(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _adminStatCard(
    String val,
    String title,
    String sub,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border(top: BorderSide(color: color, width: 4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color.withOpacity(0.3), size: 32),
            const SizedBox(height: 12),
            Text(
              val,
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: GoogleFonts.inter(fontSize: 11, color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }

  Widget _adminListTile(
    IconData icon,
    String title, {
    String? subtitle,
    Color color = Colors.black87,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: GoogleFonts.inter(fontSize: 12, color: Colors.black45),
            )
          : null,
      trailing: Icon(Icons.chevron_right, size: 20, color: Colors.grey[400]),
      onTap: onTap ?? () {},
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F4F7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: Colors.grey[600]),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            text,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
