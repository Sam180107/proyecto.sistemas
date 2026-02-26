import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- ESTADOS DEL CUBIT ---
abstract class ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Map<String, dynamic> userData;
  final User currentUser; // Para sacar el correo y la foto
  ProfileLoaded({required this.userData, required this.currentUser});
}

class ProfileError extends ProfileState {
  final String mensaje;
  ProfileError(this.mensaje);
}

// --- CUBIT ---
class ProfileCubit extends Cubit<ProfileState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _userSubscription;

  ProfileCubit() : super(ProfileLoading()) {
    _escucharDatosUsuario();
  }

  // 1. Escucha a Firestore en TIEMPO REAL
  void _escucharDatosUsuario() {
    final user = _auth.currentUser;
    if (user == null) {
      emit(ProfileError("Usuario no autenticado"));
      return;
    }

    _userSubscription = _firestore.collection('usuarios').doc(user.uid).snapshots().listen(
      (snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          emit(ProfileLoaded(userData: snapshot.data()!, currentUser: user));
        } else {
          emit(ProfileError("No se encontraron los datos del usuario en la base de datos."));
        }
      },
      onError: (error) => emit(ProfileError("Error al cargar perfil: $error")),
    );
  }

  // 2. Actualizar Teléfono
  Future<bool> actualizarTelefono(String nuevoTelefono) async {
    try {
      await _firestore.collection('usuarios').doc(_auth.currentUser!.uid).update({'telefono': nuevoTelefono});
      return true; // Éxito
    } catch (e) {
      return false; // Error
    }
  }

  // 3. Solicitar Cambio de Carrera
  Future<bool> solicitarCambioCarrera(String carreraActual, String nuevaCarrera) async {
    try {
      await _firestore.collection('solicitudes_carrera').add({
        'uid': _auth.currentUser!.uid,
        'correo': _auth.currentUser!.email,
        'carrera_actual': carreraActual,
        'nueva_carrera': nuevaCarrera,
        'estado': 'Pendiente',
        'fecha_solicitud': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // 4. Cambiar Nombre
  Future<bool> actualizarNombre(String nuevoNombre) async {
    try {
      await _auth.currentUser!.updateDisplayName(nuevoNombre);
      await _firestore.collection('usuarios').doc(_auth.currentUser!.uid).update({'nombre': nuevoNombre});
      return true;
    } catch (e) {
      return false;
    }
  }

  // 5. Restablecer Contraseña
  Future<bool> enviarCorreoPassword() async {
    try {
      await _auth.sendPasswordResetEmail(email: _auth.currentUser!.email!);
      return true;
    } catch (e) {
      return false;
    }
  }

  // 6. Eliminar Cuenta
  Future<bool> eliminarCuenta() async {
    try {
      await _auth.currentUser!.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  // 7. Cerrar Sesión
  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }

  // Siempre debemos cancelar la suscripción al cerrar la pantalla para no gastar memoria
  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}