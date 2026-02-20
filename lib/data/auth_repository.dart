import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

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
  Future<void> register({
    required String email,
    required String password,
  }) async {
    _validateInstitutionalEmail(email);

    await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // 🔑 Login
  Future<void> logIn({
    required String email,
    required String password,
  }) async {
    _validateInstitutionalEmail(email);

    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // 🚪 Logout
  Future<void> logOut() async {
    await _firebaseAuth.signOut();
  }
}