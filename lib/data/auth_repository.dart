import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Usuario actual
  User? get currentUser => _firebaseAuth.currentUser;

  // Stream de cambios de autenticación
  Stream<User?> get authStateChanges =>
      _firebaseAuth.authStateChanges();

  // 🔐 Validación de dominio institucional
  void _validateInstitutionalEmail(String email) {
    if (!email.toLowerCase().contains("unimet.edu.ve")) {
      throw Exception(
          "Debe utilizar un correo institucional @unimet.edu.ve");
    }
  }

  // 📝 Registro
  Future<User> register({
    required String email,
    required String password,
  }) async {
    _validateInstitutionalEmail(email);

    final credential =
        await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    return credential.user!;
  }

  // 🔑 Login
  Future<User> logIn({
    required String email,
    required String password,
  }) async {
    _validateInstitutionalEmail(email);

    final credential =
        await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return credential.user!;
  }

  // 🚪 Logout
  Future<void> logOut() async {
    await _firebaseAuth.signOut();
  }
}