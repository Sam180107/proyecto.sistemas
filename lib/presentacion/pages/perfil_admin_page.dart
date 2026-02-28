import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unimet_marketplace/domain/cubits/profile_cubit.dart';
import '../widgets/custom_app_bar.dart';

class PerfilAdminPage extends StatelessWidget {
  const PerfilAdminPage({super.key});

  // --- FUNCIONES DE ACCIÓN ---

  void _mostrarDialogoCerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Cerrar Sesión"),
        content: const Text("¿Estás seguro de que quieres salir del panel administrativo?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () async {
              Navigator.pop(dialogContext); // Cerramos el diálogo primero
              await context.read<ProfileCubit>().cerrarSesion();
              
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            child: const Text("Salir", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // NUEVA FUNCIÓN: Dialogo para cambiar el nombre
  void _mostrarDialogoCambiarNombre(BuildContext context, String nombreActual) {
    final TextEditingController nombreController = TextEditingController(text: nombreActual);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Cambiar Nombre", style: TextStyle(color: Color(0xFF003870))),
        content: TextField(
          controller: nombreController,
          decoration: const InputDecoration(
            labelText: "Nuevo Nombre",
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF003870), width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF003870)),
            onPressed: () {
              final nuevoNombre = nombreController.text.trim();
              if (nuevoNombre.isNotEmpty && nuevoNombre != nombreActual) {
                // Usamos el context original para llamar al Cubit y actualizar
                context.read<ProfileCubit>().actualizarNombre(nuevoNombre);
              }
              Navigator.pop(dialogContext); // Cerramos el pop-up
            },
            child: const Text("Guardar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- BUILD PRINCIPAL ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F6),
      appBar: const CustomAppBar(),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          Map<String, dynamic> userData = {};
          if (state is ProfileLoaded) {
            userData = state.userData;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "PANEL ADMINISTRATIVO", 
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF003870))
                ),
                const Text("Gestión de seguridad y métricas del sistema"),
                const SizedBox(height: 30),
                
                LayoutBuilder(
                  builder: (context, constraints) {
                    bool isDesktop = constraints.maxWidth > 900;
                    return isDesktop 
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 1, child: _buildAdminSidebar(context, userData)),
                            const SizedBox(width: 25),
                            // Pasamos userData aquí para saber el nombre actual
                            Expanded(flex: 2, child: _buildAdminMainContent(context, userData)), 
                          ],
                        )
                      : Column(
                          children: [
                            _buildAdminSidebar(context, userData),
                            const SizedBox(height: 25),
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

  // LADO IZQUIERDO: Info del Admin
  Widget _buildAdminSidebar(BuildContext context, Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15)],
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFF003870),
            child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 50),
          ),
          const SizedBox(height: 16),
          Text(
            data['nombre'] ?? "Samir Nassar", 
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const Text("Rol: Admin Sistema", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          const Divider(height: 40),
          _infoRow(Icons.email_outlined, data['correo'] ?? "admin@unimet.edu.ve"),
          _infoRow(Icons.phone_android, data['telefono'] ?? "04241000834"),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Configuraciones pronto...")));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF003870),
              minimumSize: const Size(double.infinity, 45),
            ),
            child: const Text("Configuración Avanzada", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // LADO DERECHO: Métricas de Gestión y Acciones (Ahora recibe la data del usuario)
  Widget _buildAdminMainContent(BuildContext context, Map<String, dynamic> data) {
    return Column(
      children: [
        Row(
          children: [
            _adminStatCard("12", "PETICIONES", "Cambios Carrera", Colors.orange),
            const SizedBox(width: 12),
            _adminStatCard("5", "REPORTES", "Denuncias", Colors.redAccent),
            const SizedBox(width: 12),
            _adminStatCard("28", "VALIDAR", "Libros", Colors.blue),
          ],
        ),
        const SizedBox(height: 25),
        
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
          ),
          child: Column(
            children: [
              _adminListTile(
                Icons.assignment_ind_outlined, 
                "Solicitudes de Carrera", 
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SolicitudesCarreraPage()))
              ),
              _adminListTile(
                Icons.gavel_rounded, 
                "Gestión de Reportes", 
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GestionReportesPage()))
              ),
              _adminListTile(
                Icons.check_circle_outline, 
                "Validar Publicaciones", 
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ValidarPublicacionesPage()))
              ),
              const Divider(),
              // BOTÓN PARA CAMBIAR NOMBRE (AHORA ABRE EL POP-UP)
              _adminListTile(
                Icons.edit_outlined, 
                "Cambiar Nombre", 
                onTap: () => _mostrarDialogoCambiarNombre(context, data['nombre'] ?? "")
              ),
              _adminListTile(
                Icons.logout, 
                "Cerrar Sesión", 
                color: Colors.orange, 
                onTap: () => _mostrarDialogoCerrarSesion(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _adminStatCard(String val, String title, String sub, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border(top: BorderSide(color: color, width: 4)),
        ),
        child: Column(
          children: [
            Text(val, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            Text(sub, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _adminListTile(IconData icon, String title, {Color color = Colors.black87, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: onTap ?? () {},
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

// =====================================================================
// PANTALLAS DE LOS MÓDULOS
// =====================================================================

class SolicitudesCarreraPage extends StatelessWidget {
  const SolicitudesCarreraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Solicitudes de Carrera"), backgroundColor: const Color(0xFF003870), foregroundColor: Colors.white,),
      body: const Center(
        child: Text("Aquí se mostrará la lista de estudiantes pidiendo cambiar de carrera.", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}

class GestionReportesPage extends StatelessWidget {
  const GestionReportesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gestión de Reportes"), backgroundColor: const Color(0xFF003870), foregroundColor: Colors.white,),
      body: const Center(
        child: Text("Aquí verás los usuarios o libros reportados por la comunidad.", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}

class ValidarPublicacionesPage extends StatelessWidget {
  const ValidarPublicacionesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Validar Publicaciones"), backgroundColor: const Color(0xFF003870), foregroundColor: Colors.white,),
      body: const Center(
        child: Text("Aquí aprobarás o rechazarás los libros antes de que salgan en la tienda.", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}