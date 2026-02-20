import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(AuthLoading()) {
    print("AuthCubit iniciado");

    _authRepository.authStateChanges.listen((user) {
      print("Cambio detectado en Firebase auth: $user");

      if (user != null) {
        print("Emit AuthAuthenticated");
        emit(AuthAuthenticated(user));
      } else {
        print("Emit AuthUnauthenticated");
        emit(AuthUnauthenticated());
      }
    });
  }

  Future<void> register(String email, String password) async {
    print("Intentando registro...");
    emit(AuthLoading());

    try {
      await _authRepository.register(
        email: email,
        password: password,
      );
      // Firebase listener emitirá AuthAuthenticated automáticamente
    } catch (e) {
      print("Error en registro: $e");
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> login(String email, String password) async {
    print("Intentando login...");
    emit(AuthLoading());

    try {
      await _authRepository.logIn(
        email: email,
        password: password,
      );
      // Firebase listener emitirá AuthAuthenticated automáticamente
    } catch (e) {
      print("Error en login: $e");
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> logout() async {
    print("Cerrando sesión...");
    try {
      await _authRepository.logOut();
      // Firebase listener emitirá AuthUnauthenticated automáticamente
    } catch (e) {
      print("Error en logout: $e");
      emit(AuthError("Error al cerrar sesión"));
    }
  }
}