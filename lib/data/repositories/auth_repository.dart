import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  UserModel? get currentUser {
    final user = _firebaseAuth.currentUser;
    return user != null ? UserModel.fromFirebaseUser(user) : null;
  }

  Stream<UserModel?> get authStateChanges => _firebaseAuth
      .authStateChanges()
      .map((user) => user != null ? UserModel.fromFirebaseUser(user) : null);

  void _validateInstitutionalEmail(String email) {
    if (!email.toLowerCase().contains("unimet.edu.ve")) {
      throw Exception("Debe utilizar un correo institucional @unimet.edu.ve");
    }
  }

  Future<UserModel> register({
    required String email,
    required String password,
  }) async {
    _validateInstitutionalEmail(email);
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return UserModel.fromFirebaseUser(credential.user!);
  }

  Future<UserModel> logIn({
    required String email,
    required String password,
  }) async {
    _validateInstitutionalEmail(email); // Valida el correo institucional
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return UserModel.fromFirebaseUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception("No existe un usuario con este correo.");
      } else if (e.code == 'wrong-password') {
        throw Exception("La contraseña es incorrecta.");
      } else {
        throw Exception("Error al iniciar sesión: ${e.message}");
      }
    } catch (e) {
      throw Exception("Error inesperado: ${e.toString()}");
    }
  }

  Future<void> logOut() async {
    await _firebaseAuth.signOut();
  }
}
