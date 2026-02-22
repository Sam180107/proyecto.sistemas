import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String nombreUsuario;
  late String correoUsuario;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    nombreUsuario = user?.displayName ?? "Usuario";
    correoUsuario = user?.email ?? "sin_correo@unimet.edu.ve";
  }

  void _lanzarMensaje(String texto, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _funcionCambiarFoto() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cambiar Foto de Perfil"),
        content: const Text("¿Desde dónde quieres seleccionar la imagen?"),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.photo_library),
            label: const Text("Galería"),
            onPressed: () {
              Navigator.pop(context);
              _lanzarMensaje("Abrir Galería (Próximamente)", Colors.blue);
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.camera_alt),
            label: const Text("Cámara"),
            onPressed: () {
              Navigator.pop(context);
              _lanzarMensaje("Abrir Cámara (Próximamente)", Colors.blue);
            },
          ),
        ],
      ),
    );
  }

  void _funcionCambiarNombre() {
    TextEditingController nombreCtrl = TextEditingController(text: nombreUsuario);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Editar Nombre"),
        content: TextField(
          controller: nombreCtrl,
          decoration: const InputDecoration(labelText: "Nuevo nombre público"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              try {
                await _auth.currentUser?.updateDisplayName(nombreCtrl.text);
                setState(() => nombreUsuario = nombreCtrl.text);
                if (!mounted) return;
                Navigator.pop(context);
                _lanzarMensaje("Nombre actualizado", Colors.blue);
              } catch (e) {
                _lanzarMensaje("Error al actualizar", Colors.red);
              }
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  void _funcionPassword() async {
    try {
      await _auth.sendPasswordResetEmail(email: correoUsuario);
      _lanzarMensaje("Correo enviado a $correoUsuario", Colors.blueAccent);
    } catch (e) {
      _lanzarMensaje("Error al enviar correo", Colors.red);
    }
  }

  void _funcionLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cerrar Sesión"),
        content: const Text("¿Estás seguro de que quieres salir?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () async {
              await _auth.signOut();
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, '/landing', (route) => false);
            },
            child: const Text("Salir", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _funcionEliminar() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Eliminar de BookSwap", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: const Text("Esta acción es irreversible. Se borrarán tus datos de usuario."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await _auth.currentUser?.delete();
                if (!mounted) return;
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(context, '/landing', (route) => false);
                _lanzarMensaje("Cuenta eliminada de BookSwap", Colors.red);
              } catch (e) {
                _lanzarMensaje("Por seguridad, inicia sesión de nuevo antes de eliminar tu cuenta", Colors.red);
              }
            },
            child: const Text("Confirmar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text('BookSwap', style: TextStyle(color: Color(0xFF007BFF), fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Mi Perfil", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const Text("Gestiona tu cuenta y preferencias", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            LayoutBuilder(
              builder: (context, constraints) {
                bool isDesktop = constraints.maxWidth > 800;
                Widget content = Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 1, child: _buildUserCard()),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _buildStatCard("18", "Ventas"),
                              const SizedBox(width: 10),
                              _buildStatCard("6", "Intercambios"),
                              const SizedBox(width: 10),
                              _buildStatCard("24", "Reseñas"),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildReputationCard(),
                        ],
                      ),
                    ),
                  ],
                );
                if (!isDesktop) {
                  content = Column(
                    children: [
                      _buildUserCard(),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          _buildStatCard("18", "Ventas"),
                          const SizedBox(width: 10),
                          _buildStatCard("6", "Intercambios"),
                          const SizedBox(width: 10),
                          _buildStatCard("24", "Reseñas"),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildReputationCard(),
                    ],
                  );
                }
                return content;
              },
            ),
            const SizedBox(height: 30),
            _buildSettingsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black12)),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              InkWell(
                onTap: _funcionCambiarFoto,
                borderRadius: BorderRadius.circular(50),
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: const Color(0xFF0089A7),
                  backgroundImage: _auth.currentUser?.photoURL != null
                      ? NetworkImage(_auth.currentUser!.photoURL!)
                      : null,
                  child: _auth.currentUser?.photoURL == null
                      ? Text(nombreUsuario.isNotEmpty ? nombreUsuario[0].toUpperCase() : "U", style: const TextStyle(color: Colors.white, fontSize: 34))
                      : null,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade200, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt, size: 16, color: Color(0xFF007BFF)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(nombreUsuario, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18), textAlign: TextAlign.center),
          const Text("Ingeniería Civil\n7mo Semestre", style: TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
          const Divider(height: 30),
          _infoLine(Icons.location_on_outlined, "Campus Norte"),
          const SizedBox(height: 8),
          _infoLine(Icons.calendar_today_outlined, "Enero 2025"),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _lanzarMensaje("Chat próximamente", Colors.blue),
            icon: const Icon(Icons.chat_bubble_outline, size: 16),
            label: const Text("Enviar Mensaje"),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF007BFF), foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 45), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(String val, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.black12)),
        child: Column(children: [
          Text(val, style: const TextStyle(fontSize: 22, color: Color(0xFF007BFF), fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ]),
      ),
    );
  }

  Widget _buildReputationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.black12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [Icon(Icons.shield_outlined, color: Colors.teal, size: 18), SizedBox(width: 8), Text("Reputación", style: TextStyle(fontWeight: FontWeight.bold))]),
          const SizedBox(height: 15),
          _progressRow("Calificación General", 0.9, "4.8"),
          const SizedBox(height: 15),
          _progressRow("Tasa de Respuesta", 0.95, "95%"),
        ],
      ),
    );
  }

  Widget _buildSettingsList() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.black12)),
      child: Column(
        children: [
          const ListTile(leading: Icon(Icons.settings_outlined, color: Colors.black87), title: Text("Configuración de Cuenta", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87))),
          const Divider(height: 1, color: Colors.black12),
          _buildOption(Icons.person_outline, "Cambiar Nombre", _funcionCambiarNombre),
          const Divider(height: 1, color: Colors.black12),
          _buildOption(Icons.lock_outline, "Cambiar Contraseña", _funcionPassword),
          const Divider(height: 1, color: Colors.black12),
          _buildOption(Icons.logout, "Cerrar Sesión", _funcionLogout, color: Colors.orange),
          const Divider(height: 1, color: Colors.black12),
          _buildOption(Icons.delete_forever_outlined, "Eliminar Cuenta", _funcionEliminar, color: Colors.red),
        ],
      ),
    );
  }

  Widget _buildOption(IconData icon, String title, VoidCallback tap, {Color color = Colors.black87}) {
    return ListTile(
      leading: Icon(icon, color: color, size: 20),
      title: Text(title, style: TextStyle(color: color, fontSize: 15)),
      trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
      onTap: tap,
    );
  }

  Widget _infoLine(IconData icon, String txt) => Row(children: [Icon(icon, size: 16, color: Colors.grey), const SizedBox(width: 8), Text(txt, style: const TextStyle(fontSize: 12, color: Colors.grey))]);

  Widget _progressRow(String label, double val, String txt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(label, style: const TextStyle(fontSize: 13)), Text(txt, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))]
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: val, backgroundColor: Colors.blue[50], color: const Color(0xFF007BFF), minHeight: 8, borderRadius: BorderRadius.circular(5))
      ]
    );
  }
}