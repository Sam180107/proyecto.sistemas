import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ProfileState {}
class ProfileInitial extends ProfileState {}
class ProfileLoading extends ProfileState {}
class ProfileLoaded extends ProfileState {
  final Map<String, dynamic> userData;
  final User currentUser;
  ProfileLoaded({required this.userData, required this.currentUser});
}
class ProfileError extends ProfileState {
  final String mensaje;
  ProfileError(this.mensaje);
}

class ProfileCubit extends Cubit<ProfileState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _userSubscription;

  ProfileCubit() : super(ProfileLoading()) {
    _escucharDatosUsuario();
  }

  void _escucharDatosUsuario() {
    _auth.authStateChanges().listen((user) {
      if (user == null) {
        _userSubscription?.cancel();
        emit(ProfileInitial());
        return;
      }
      _userSubscription?.cancel();
      _userSubscription = _firestore.collection('usuarios').doc(user.uid).snapshots().listen(
        (snapshot) {
          if (snapshot.exists && snapshot.data() != null) {
            emit(ProfileLoaded(userData: snapshot.data()!, currentUser: user));
          } else {
            emit(ProfileError("Usuario no encontrado en base de datos."));
          }
        },
        onError: (error) => emit(ProfileError("Error de red: $error")),
      );
    });
  }

  Future<bool> actualizarTelefono(String nuevoTelefono) async {
    try {
      await _firestore.collection('usuarios').doc(_auth.currentUser!.uid).update({'telefono': nuevoTelefono});
      return true;
    } catch (e) { return false; }
  }

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
    } catch (e) { return false; }
  }

  Future<bool> actualizarNombre(String nuevoNombre) async {
    try {
      await _auth.currentUser!.updateDisplayName(nuevoNombre);
      await _firestore.collection('usuarios').doc(_auth.currentUser!.uid).update({'nombre': nuevoNombre});
      return true;
    } catch (e) { return false; }
  }

  Future<bool> enviarCorreoPassword() async {
    try {
      await _auth.sendPasswordResetEmail(email: _auth.currentUser!.email!);
      return true;
    } catch (e) { return false; }
  }

  Future<bool> eliminarCuenta() async {
    try {
      await _auth.currentUser!.delete();
      return true;
    } catch (e) { return false; }
  }

  Future<void> cerrarSesion() async {
    try {
      if (_userSubscription != null) {
        await _userSubscription!.cancel();
        _userSubscription = null;
      }
      await _auth.signOut();
      emit(ProfileInitial());
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}