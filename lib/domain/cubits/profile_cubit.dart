import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

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
        debugPrint('ProfileCubit: User is null, emitting ProfileInitial');
        _userSubscription?.cancel();
        emit(ProfileInitial());
        return;
      }
      debugPrint('ProfileCubit: User authenticated: ${user.uid}');
      _userSubscription?.cancel();
      _userSubscription = _firestore.collection('usuarios').doc(user.uid).snapshots().listen(
        (snapshot) {
          debugPrint('ProfileCubit: Snapshot received for ${user.uid}, exists: ${snapshot.exists}');
          if (snapshot.exists && snapshot.data() != null) {
            emit(ProfileLoaded(userData: snapshot.data()!, currentUser: user));
          } else {
            debugPrint('ProfileCubit: User document not found for ${user.uid}. Using Auth data fallback.');
            // Fallback: Create a temporary userData map from Auth info
            final fallbackData = {
              'nombre': user.displayName ?? 'Usuario',
              'email': user.email ?? '',
              'rol': 'Usuario', // Default role
              'carrera': 'No especificada',
              'telefono': '',
            };
            emit(ProfileLoaded(userData: fallbackData, currentUser: user));
            
            // Optional: Try to create the document if it's missing (Self-healing)
            _firestore.collection('usuarios').doc(user.uid).set(
              {...fallbackData, 'fechaRegistro': FieldValue.serverTimestamp()},
              SetOptions(merge: true),
            ).catchError((e) => debugPrint("Error creating missing profile: $e"));
          }
        },
        onError: (error) {
          debugPrint('ProfileCubit: Error fetching user data: $error');
          emit(ProfileError("Error de red: $error"));
        },
      );
    });
  }

  Future<bool> actualizarTelefono(String nuevoTelefono) async {
  try {
    // Limpiamos un poco el input antes de guardarlo para que sea estándar
    String tlfLimpio = nuevoTelefono.trim();
    
    await _firestore
        .collection('usuarios')
        .doc(_auth.currentUser!.uid)
        .update({'telefono': tlfLimpio}); // Asegúrate que en Firestore la llave sea 'telefono'
    return true;
  } catch (e) {
    return false;
  }
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