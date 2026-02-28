import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unimet_marketplace/domain/cubits/profile_cubit.dart';
import 'perfil_admin_page.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit(),
      child: const _PerfilPageView(),
    );
  }
}

class _PerfilPageView extends StatefulWidget {
  const _PerfilPageView();

  @override
  State<_PerfilPageView> createState() => _PerfilPageViewState();
}

class _PerfilPageViewState extends State<_PerfilPageView> {
  final List<String> opcionesCarrera = [
    'Ingeniería Civil', 'Ingeniería Eléctrica', 'Ingeniería Mecánica',
    'Ingeniería de Producción', 'Ingeniería Química', 'Ingeniería de Sistemas',
    'TSU en Desarrollo de Sistemas Inteligentes', 'Ciencias Administrativas',
    'Contaduría Pública', 'Economía Empresarial', 'Turismo Sostenible',
    'Derecho', 'Estudios Liberales', 'Estudios Internacionales',
    'Comunicación Social y Empresarial', 'Idiomas Modernos', 'Educación',
    'Psicología', 'Matemáticas Industriales',
  ];

  void _lanzarMensaje(String texto, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // --- FUNCIONES QUE LE HABLAN AL CUBIT ---

  void _funcionCambiarTelefono(String telefonoActual) {
    TextEditingController telefonoCtrl = TextEditingController(text: telefonoActual);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Actualizar Teléfono"),
        content: TextField(
          controller: telefonoCtrl,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: "Nuevo número", prefixIcon: Icon(Icons.phone)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              bool exito = await context.read<ProfileCubit>().actualizarTelefono(telefonoCtrl.text);
              if (!mounted) return;
              Navigator.pop(dialogContext);
              exito ? _lanzarMensaje("Teléfono actualizado", Colors.green) : _lanzarMensaje("Error", Colors.red);
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  void _funcionCambiarCarrera(String carreraActual) {
    String? nuevaCarrera;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Cambio de Carrera"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Esta solicitud será enviada a un administrador.", style: TextStyle(fontSize: 13, color: Colors.black54)),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Nueva Carrera', border: OutlineInputBorder()),
              items: opcionesCarrera.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis))).toList(),
              onChanged: (valor) => nuevaCarrera = valor,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              if (nuevaCarrera != null) {
                bool exito = await context.read<ProfileCubit>().solicitarCambioCarrera(carreraActual, nuevaCarrera!);
                if (!mounted) return;
                Navigator.pop(dialogContext);
                exito ? _lanzarMensaje("Solicitud enviada", Colors.blue) : _lanzarMensaje("Error", Colors.red);
              }
            },
            child: const Text("Enviar Solicitud"),
          ),
        ],
      ),
    );
  }

  void _funcionCambiarNombre(String nombreActual) {
    TextEditingController nombreCtrl = TextEditingController(text: nombreActual);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Editar Nombre"),
        content: TextField(
          controller: nombreCtrl,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: "Nuevo nombre público"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              bool exito = await context.read<ProfileCubit>().actualizarNombre(nombreCtrl.text);
              if (!mounted) return;
              Navigator.pop(dialogContext);
              exito ? _lanzarMensaje("Nombre actualizado", Colors.green) : _lanzarMensaje("Error", Colors.red);
            },
            child: const Text("Guardar"),
          ),
        ],
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
          TextButton.icon(icon: const Icon(Icons.photo_library), label: const Text("Galería"), onPressed: () { Navigator.pop(context); _lanzarMensaje("Próximamente", Colors.blue); }),
          TextButton.icon(icon: const Icon(Icons.camera_alt), label: const Text("Cámara"), onPressed: () { Navigator.pop(context); _lanzarMensaje("Próximamente", Colors.blue); }),
        ],
      ),
    );
  }

  void _funcionPassword() async {
    bool exito = await context.read<ProfileCubit>().enviarCorreoPassword();
    exito ? _lanzarMensaje("Correo de restablecimiento enviado", Colors.blueAccent) : _lanzarMensaje("Error", Colors.red);
  }

  void _funcionLogout() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Cerrar Sesión"),
        content: const Text("¿Estás seguro de que quieres salir?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await context.read<ProfileCubit>().cerrarSesion();
              if (!mounted) return;
              Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil('/', (route) => false);
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
      builder: (dialogContext) => AlertDialog(
        title: const Text("Eliminar Cuenta", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: const Text("Esta acción es irreversible."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              bool exito = await context.read<ProfileCubit>().eliminarCuenta();
              if (!mounted) return;
              if (exito) {
                Navigator.pop(dialogContext);
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                _lanzarMensaje("Cuenta eliminada", Colors.red);
              } else {
                _lanzarMensaje("Error de seguridad al eliminar", Colors.red);
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
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) return const Center(child: CircularProgressIndicator());
          if (state is ProfileError) return Center(child: Text(state.mensaje));
          
          if (state is ProfileLoaded) {
            final userData = state.userData;
            final userAuth = state.currentUser;

            if (userData['rol'] == 'Admin') return const PerfilAdminPage();

            return SingleChildScrollView(
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
                          Expanded(flex: 1, child: _buildUserCard(userData, userAuth.photoURL)),
                          const SizedBox(width: 20),
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                Row(children: [
                                  _buildStatCard("18", "Ventas"), const SizedBox(width: 10),
                                  _buildStatCard("6", "Intercambios"), const SizedBox(width: 10),
                                  _buildStatCard("24", "Reseñas"),
                                ]),
                                const SizedBox(height: 20),
                                _buildReputationCard(),
                              ],
                            ),
                          ),
                        ],
                      );
                      
                      if (!isDesktop) {
                        content = Column(children: [
                          _buildUserCard(userData, userAuth.photoURL),
                          const SizedBox(height: 20),
                          Row(children: [
                            _buildStatCard("18", "Ventas"), const SizedBox(width: 10),
                            _buildStatCard("6", "Intercambios"), const SizedBox(width: 10),
                            _buildStatCard("24", "Reseñas"),
                          ]),
                          const SizedBox(height: 20),
                          _buildReputationCard(),
                        ]);
                      }
                      return content;
                    },
                  ),
                  const SizedBox(height: 30),
                  _buildSettingsList(userData),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // --- WIDGETS DE INTERFAZ REINTEGRADOS ---

  Widget _buildUserCard(Map<String, dynamic> userData, String? photoURL) {
    String nombre = userData['nombre'] ?? "Usuario";
    String rol = userData['rol'] ?? "Estudiante";
    String espec = rol == 'Estudiante' ? (userData['carrera'] ?? "") : (userData['departamento'] ?? "");
    String tlf = userData['telefono'] ?? "Sin teléfono";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black12)),
      child: Column(children: [
        Stack(alignment: Alignment.bottomRight, children: [
          InkWell(
            onTap: _funcionCambiarFoto,
            child: CircleAvatar(radius: 45, backgroundColor: const Color(0xFF0089A7), 
              backgroundImage: photoURL != null ? NetworkImage(photoURL) : null,
              child: photoURL == null ? Text(nombre.isNotEmpty ? nombre[0].toUpperCase() : "U", style: const TextStyle(color: Colors.white, fontSize: 34)) : null),
          ),
          Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.camera_alt, size: 16, color: Color(0xFF007BFF))),
        ]),
        const SizedBox(height: 15),
        Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text("$espec\n$rol", textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const Divider(height: 30),
        _infoLine(Icons.phone_outlined, tlf),
        _infoLine(Icons.location_on_outlined, "Unimet, Caracas"),
        const SizedBox(height: 20),
        ElevatedButton.icon(onPressed: () => _lanzarMensaje("Próximamente", Colors.blue), icon: const Icon(Icons.chat_bubble_outline, size: 16), label: const Text("Enviar Mensaje"),
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF007BFF), foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 45), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)))),
      ]),
    );
  }

  Widget _buildStatCard(String val, String label) {
    return Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.black12)),
    child: Column(children: [Text(val, style: const TextStyle(fontSize: 22, color: Color(0xFF007BFF), fontWeight: FontWeight.bold)), Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11))])));
  }

  Widget _buildReputationCard() {
    return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.black12)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [Icon(Icons.shield_outlined, color: Colors.teal, size: 18), SizedBox(width: 8), Text("Reputación", style: TextStyle(fontWeight: FontWeight.bold))]),
      const SizedBox(height: 15),
      _progressRow("Calificación General", 0.9, "4.8"),
      const SizedBox(height: 15),
      _progressRow("Tasa de Respuesta", 0.95, "95%"),
    ]));
  }

  Widget _buildSettingsList(Map<String, dynamic> userData) {
    String rol = userData['rol'] ?? "Estudiante";
    return Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.black12)),
    child: Column(children: [
      _buildOption(Icons.person_outline, "Cambiar Nombre", () => _funcionCambiarNombre(userData['nombre'] ?? "")),
      const Divider(height: 1),
      _buildOption(Icons.phone_android, "Cambiar Teléfono", () => _funcionCambiarTelefono(userData['telefono'] ?? "")),
      const Divider(height: 1),
      if (rol == 'Estudiante') ...[
        _buildOption(Icons.school_outlined, "Solicitar Cambio de Carrera", () => _funcionCambiarCarrera(userData['carrera'] ?? "")),
        const Divider(height: 1),
      ],
      _buildOption(Icons.lock_outline, "Cambiar Contraseña", _funcionPassword),
      const Divider(height: 1),
      _buildOption(Icons.logout, "Cerrar Sesión", _funcionLogout, color: Colors.orange),
      const Divider(height: 1),
      _buildOption(Icons.delete_forever_outlined, "Eliminar Cuenta", _funcionEliminar, color: Colors.red),
    ]));
  }

  Widget _buildOption(IconData icon, String title, VoidCallback tap, {Color color = Colors.black87}) {
    return ListTile(leading: Icon(icon, color: color, size: 20), title: Text(title, style: TextStyle(color: color, fontSize: 15)), trailing: const Icon(Icons.chevron_right, size: 18), onTap: tap);
  }

  Widget _infoLine(IconData icon, String txt) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Row(children: [Icon(icon, size: 16, color: Colors.grey), const SizedBox(width: 8), Text(txt, style: const TextStyle(fontSize: 12, color: Colors.grey))]),
  );

  Widget _progressRow(String label, double val, String txt) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontSize: 13)), Text(txt, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))]),
      const SizedBox(height: 8),
      LinearProgressIndicator(value: val, backgroundColor: Colors.blue[50], color: const Color(0xFF007BFF), minHeight: 8, borderRadius: BorderRadius.circular(5))
    ]);
  }
}