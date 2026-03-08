import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unimet_marketplace/domain/cubits/profile_cubit.dart';
import 'package:unimet_marketplace/domain/cubits/rating_cubit.dart';
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
    'Ingeniería Civil',
    'Ingeniería Eléctrica',
    'Ingeniería Mecánica',
    'Ingeniería de Producción',
    'Ingeniería Química',
    'Ingeniería de Sistemas',
    'TSU en Desarrollo de Sistemas Inteligentes',
    'Ciencias Administrativas',
    'Contaduría Pública',
    'Economía Empresarial',
    'Turismo Sostenible',
    'Derecho',
    'Estudios Liberales',
    'Estudios Internacionales',
    'Comunicación Social y Empresarial',
    'Idiomas Modernos',
    'Educación',
    'Psicología',
    'Matemáticas Industriales',
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

  void _funcionCambiarTelefono(String telefonoActual) {
    TextEditingController telefonoCtrl = TextEditingController(
      text: telefonoActual,
    );
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Actualizar Teléfono"),
        content: TextField(
          controller: telefonoCtrl,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: "Nuevo número",
            prefixIcon: Icon(Icons.phone),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              bool exito = await context
                  .read<ProfileCubit>()
                  .actualizarTelefono(telefonoCtrl.text);
              if (!mounted) return;
              Navigator.pop(dialogContext);
              exito
                  ? _lanzarMensaje("Teléfono actualizado", Colors.green)
                  : _lanzarMensaje("Error", Colors.red);
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
            const Text(
              "Esta solicitud será enviada a un administrador.",
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Nueva Carrera',
                border: OutlineInputBorder(),
              ),
              items: opcionesCarrera
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(c, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: (valor) => nuevaCarrera = valor,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nuevaCarrera != null) {
                bool exito = await context
                    .read<ProfileCubit>()
                    .solicitarCambioCarrera(carreraActual, nuevaCarrera!);
                if (!mounted) return;
                Navigator.pop(dialogContext);
                exito
                    ? _lanzarMensaje("Solicitud enviada", Colors.blue)
                    : _lanzarMensaje("Error", Colors.red);
              }
            },
            child: const Text("Enviar Solicitud"),
          ),
        ],
      ),
    );
  }

  void _funcionCambiarNombre(String nombreActual) {
    TextEditingController nombreCtrl = TextEditingController(
      text: nombreActual,
    );
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
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              bool exito = await context.read<ProfileCubit>().actualizarNombre(
                nombreCtrl.text,
              );
              if (!mounted) return;
              Navigator.pop(dialogContext);
              exito
                  ? _lanzarMensaje("Nombre actualizado", Colors.green)
                  : _lanzarMensaje("Error", Colors.red);
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
          TextButton.icon(
            icon: const Icon(Icons.photo_library),
            label: const Text("Galería"),
            onPressed: () {
              Navigator.pop(context);
              _lanzarMensaje("Próximamente", Colors.blue);
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.camera_alt),
            label: const Text("Cámara"),
            onPressed: () {
              Navigator.pop(context);
              _lanzarMensaje("Próximamente", Colors.blue);
            },
          ),
        ],
      ),
    );
  }

  void _funcionPassword() async {
    bool exito = await context.read<ProfileCubit>().enviarCorreoPassword();
    exito
        ? _lanzarMensaje(
            "Correo de restablecimiento enviado",
            Colors.blueAccent,
          )
        : _lanzarMensaje("Error", Colors.red);
  }

  void _funcionLogout() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Cerrar Sesión"),
        content: const Text("¿Estás seguro de que quieres salir?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await context.read<ProfileCubit>().cerrarSesion();
              if (!mounted) return;
              Navigator.of(
                context,
                rootNavigator: true,
              ).pushNamedAndRemoveUntil('/', (route) => false);
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
        title: const Text(
          "Eliminar Cuenta",
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: const Text("Esta acción es irreversible."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              bool exito = await context.read<ProfileCubit>().eliminarCuenta();
              if (!mounted) return;
              if (exito) {
                Navigator.pop(dialogContext);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
                _lanzarMensaje("Cuenta eliminada", Colors.red);
              } else {
                _lanzarMensaje("Error de seguridad al eliminar", Colors.red);
              }
            },
            child: const Text(
              "Confirmar",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (arguments != null && arguments['isOtherUser'] == true) {
      return _buildOtherUserProfile(arguments);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'BookSwap',
          style: TextStyle(
            color: Color(0xFF007BFF),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading)
            return const Center(child: CircularProgressIndicator());
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
                  const Text(
                    "Mi Perfil",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Gestiona tu cuenta y preferencias",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 30),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      bool isDesktop = constraints.maxWidth > 800;
                      Widget content = Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: _buildUserCard(userData, userAuth.photoURL),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                _buildRealStatCards(userAuth.uid),
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
                            _buildUserCard(userData, userAuth.photoURL),
                            const SizedBox(height: 20),
                            _buildRealStatCards(userAuth.uid),
                            const SizedBox(height: 20),
                            _buildReputationCard(),
                          ],
                        );
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

  Widget _buildOtherUserProfile(Map<String, dynamic> arguments) {
    String nombre = arguments['vendedor'] ?? 'Usuario';
    String carrera = arguments['carrera'] ?? 'Estudiante';
    String iniciales = arguments['iniciales'] ?? 'U';
    String rol = arguments['rol'] ?? 'Estudiante';
    String userId = arguments['userId'] ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RatingCubit>().cargarValoraciones(userId);
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'BookSwap',
          style: TextStyle(
            color: Color(0xFF007BFF),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Perfil del Vendedor",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Información del usuario",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: const Color(0xFF0089A7),
                    child: Text(
                      iniciales,
                      style: const TextStyle(color: Colors.white, fontSize: 34),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    "$carrera\n$rol",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const Divider(height: 30),
                  _buildRatingSection(),
                  const SizedBox(height: 20),
                  _infoLine(Icons.location_on_outlined, "Unimet, Caracas"),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Placeholder for send message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Función de enviar mensaje próximamente',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.message),
                    label: const Text('Enviar Mensaje'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Estadísticas del vendedor
            _buildRealStatCards(userId),
            const SizedBox(height: 20),
            _buildReputationCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    return BlocBuilder<RatingCubit, RatingState>(
      builder: (context, state) {
        if (state is RatingLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is RatingError) {
          return Text(
            'Error: ${state.mensaje}',
            style: const TextStyle(color: Colors.red),
          );
        }
        if (state is RatingLoaded) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStarRating(state.promedio),
                  const SizedBox(width: 10),
                  Text(
                    state.promedio > 0
                        ? '${state.promedio.toStringAsFixed(1)} (${state.totalValoraciones})'
                        : 'Sin valoraciones',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () => _mostrarDialogoValoracion(context),
                icon: const Icon(Icons.star_rate),
                label: const Text('Calificar Usuario'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 40),
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor()
              ? Icons.star
              : (index < rating && rating % 1 != 0)
              ? Icons.star_half
              : Icons.star_border,
          color: Colors.amber,
          size: 24,
        );
      }),
    );
  }

  void _mostrarDialogoValoracion(BuildContext context) {
    int estrellasSeleccionadas = 0;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Calificar Usuario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('¿Cuántas estrellas le das a este vendedor?'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < estrellasSeleccionadas
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() => estrellasSeleccionadas = index + 1);
                    },
                  );
                }),
              ),
              Text(
                estrellasSeleccionadas > 0
                    ? '$estrellasSeleccionadas estrella${estrellasSeleccionadas > 1 ? 's' : ''}'
                    : 'Selecciona estrellas',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: estrellasSeleccionadas > 0
                  ? () async {
                      final success = await context
                          .read<RatingCubit>()
                          .enviarValoracion(estrellasSeleccionadas);
                      if (mounted) {
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? '¡Valoración guardada!'
                                  : 'Error al guardar valoración',
                            ),
                          ),
                        );
                      }
                    }
                  : null,
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> userData, String? photoURL) {
    String nombre = userData['nombre'] ?? "Usuario";
    String rol = userData['rol'] ?? "Estudiante";
    String espec = rol == 'Estudiante'
        ? (userData['carrera'] ?? "")
        : (userData['departamento'] ?? "");
    String tlf = userData['telefono'] ?? "Sin teléfono";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: _funcionCambiarFoto,
            child: CircleAvatar(
              radius: 45,
              backgroundColor: const Color(0xFF0089A7),
              backgroundImage: photoURL != null ? NetworkImage(photoURL) : null,
              child: photoURL == null
                  ? Text(
                      nombre.isNotEmpty ? nombre[0].toUpperCase() : "U",
                      style: const TextStyle(color: Colors.white, fontSize: 34),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            nombre,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            "$espec\n$rol",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const Divider(height: 30),
          _infoLine(Icons.phone_outlined, tlf),
          _infoLine(Icons.location_on_outlined, "Unimet, Caracas"),
        ],
      ),
    );
  }

  Widget _buildRealStatCards(String userId) {
    return FutureBuilder<Map<String, int>>(
      future: _fetchUserStats(userId),
      builder: (context, snapshot) {
        final ventas = snapshot.data?['ventas'] ?? 0;
        final intercambios = snapshot.data?['intercambios'] ?? 0;
        final resenas = snapshot.data?['resenas'] ?? 0;

        return Row(
          children: [
            _buildStatCard(ventas.toString(), "Ventas"),
            const SizedBox(width: 10),
            _buildStatCard(intercambios.toString(), "Intercambios"),
            const SizedBox(width: 10),
            _buildStatCard(resenas.toString(), "Reseñas"),
          ],
        );
      },
    );
  }

  Future<Map<String, int>> _fetchUserStats(String userId) async {
    int ventas = 0;
    int intercambios = 0;
    int resenas = 0;

    try {
      final librosSnapshot = await FirebaseFirestore.instance
          .collection('libros')
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in librosSnapshot.docs) {
        final data = doc.data();
        final tipo = data['tipoTransaccion'] ?? data['tipo'] ?? 'Venta';
        if (tipo == 'Intercambio') {
          intercambios++;
        } else {
          ventas++;
        }
      }
      final valoracionesSnapshot = await FirebaseFirestore.instance
          .collection('valoraciones')
          .where('vendedorId', isEqualTo: userId)
          .get();
      resenas = valoracionesSnapshot.docs.length;
    } catch (e) {
      debugPrint('Error al obtener estadísticas del usuario: $e');
    }

    return {'ventas': ventas, 'intercambios': intercambios, 'resenas': resenas};
  }

  Widget _buildStatCard(String val, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          children: [
            Text(
              val,
              style: const TextStyle(
                fontSize: 22,
                color: Color(0xFF007BFF),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReputationCard() {
    return BlocBuilder<RatingCubit, RatingState>(
      builder: (context, state) {
        double calificacion = 0.0;
        String calificacionText = "0.0";
        if (state is RatingLoaded && state.totalValoraciones > 0) {
          calificacion = state.promedio / 5.0;
          calificacionText = state.promedio.toStringAsFixed(1);
        }
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.shield_outlined, color: Colors.teal, size: 18),
                  SizedBox(width: 8),
                  Text(
                    "Reputación",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              _progressRow(
                "Calificación General",
                calificacion,
                calificacionText,
              ),
              const SizedBox(height: 15),
              _progressRow("Tasa de Respuesta", 0.95, "95%"),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsList(Map<String, dynamic> userData) {
    String rol = userData['rol'] ?? "Estudiante";
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          _buildOption(
            Icons.person_outline,
            "Cambiar Nombre",
            () => _funcionCambiarNombre(userData['nombre'] ?? ""),
          ),
          const Divider(height: 1),
          _buildOption(
            Icons.phone_android,
            "Cambiar Teléfono",
            () => _funcionCambiarTelefono(userData['telefono'] ?? ""),
          ),
          const Divider(height: 1),
          if (rol == 'Estudiante') ...[
            _buildOption(
              Icons.school_outlined,
              "Solicitar Cambio de Carrera",
              () => _funcionCambiarCarrera(userData['carrera'] ?? ""),
            ),
            const Divider(height: 1),
          ],
          _buildOption(
            Icons.lock_outline,
            "Cambiar Contraseña",
            _funcionPassword,
          ),
          const Divider(height: 1),
          _buildOption(
            Icons.logout,
            "Cerrar Sesión",
            _funcionLogout,
            color: Colors.orange,
          ),
          const Divider(height: 1),
          _buildOption(
            Icons.delete_forever_outlined,
            "Eliminar Cuenta",
            _funcionEliminar,
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
    IconData icon,
    String title,
    VoidCallback tap, {
    Color color = Colors.black87,
  }) {
    return ListTile(
      leading: Icon(icon, color: color, size: 20),
      title: Text(title, style: TextStyle(color: color, fontSize: 15)),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: tap,
    );
  }

  Widget _infoLine(IconData icon, String txt) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(txt, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    ),
  );

  Widget _progressRow(String label, double val, String txt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13)),
            Text(
              txt,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: val,
          backgroundColor: Colors.blue[50],
          color: const Color(0xFF007BFF),
          minHeight: 8,
          borderRadius: BorderRadius.circular(5),
        ),
      ],
    );
  }
}
