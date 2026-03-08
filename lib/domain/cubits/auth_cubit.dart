import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/repositories/auth_repository.dart';
import '../entities/auth_state.dart';
import 'package:unimet_marketplace/data/models/user_model.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(AuthLoading()) {
    _authRepository.authStateChanges.listen((userModel) {
      if (userModel != null) {
        emit(AuthAuthenticated(userModel));
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }

  Future<void> register({
    required String email, 
    required String password,
    required String rol,
    required String nombre,
    required String carrera, 
    required String telefono,
    required String cedula, // <-- NUEVO PARÁMETRO
  }) async {
    emit(AuthLoading());
    try {
      // 1. Registramos el correo y contraseña a través de tu repositorio
      await _authRepository.register(email: email, password: password);
      
      // 2. Obtenemos el ID del usuario recién creado en Firebase Auth
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        // 3. Preparamos los datos base que comparten estudiantes y profesores
        Map<String, dynamic> datosUsuario = {
          'rol': rol,
          'nombre': nombre,
          'telefono': telefono,
          'correo': email,
          'cedula': cedula, // <-- GUARDAMOS LA CÉDULA/CARNET EN FIRESTORE
          'fechaRegistro': FieldValue.serverTimestamp(),
        };

        // 4. Lógica inteligente para la Base de Datos
        if (rol == 'Estudiante') {
          datosUsuario['carrera'] = carrera;
        } else {
          datosUsuario['departamento'] = carrera; 
        }

        // 5. Guardamos en Firestore
        await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).set(datosUsuario);
      }

      // 6. Emitimos el estado autenticado para que la pantalla sepa que terminó
      if (user != null) {
        emit(AuthAuthenticated(UserModel.fromFirebaseUser(user)));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final userModel = await _authRepository.logIn(
        email: email,
        password: password,
      );
      emit(AuthAuthenticated(userModel));
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    try {
      await _authRepository.logOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError("Error al cerrar sesión"));
    }
  }
}