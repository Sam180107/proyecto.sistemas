import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import '../entities/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(AuthLoading()) {
    _authRepository.authStateChanges.listen((user) {
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }

  Future<void> register(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.register(
        email: email,
        password: password,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.logIn(
        email: email,
        password: password,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString())); // Emitir el error capturado
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
