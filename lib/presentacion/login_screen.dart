import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart'; // Asegúrate de haber creado este archivo
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLogin = true; // Controla si estamos en Entrar o Registrar
  bool isPasswordVisible = false; // Track password visibility

  // Función para mostrar mensajes en la parte inferior (Snackbars)
  void _mostrarMensaje(String texto, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Lógica de Autenticación con Traducción de Errores
  Future<void> autenticar() async {
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _mostrarMensaje("Por favor, llena todos los campos", Colors.orange);
      return;
    }

    if (!isLogin && !email.endsWith('@correo.unimet.edu.ve')) {
      _mostrarMensaje(
        "Solo se permiten correos @correo.unimet.edu.ve",
        Colors.red,
      );
      return;
    }

    try {
      if (isLogin) {
        // INICIAR SESIÓN
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        // REGISTRAR CUENTA
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        _mostrarMensaje("¡Usuario registrado con éxito!", Colors.green);
      }

      // NAVEGACIÓN AL HOME (LA APP COMO TAL)
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // TRADUCTOR DE ERRORES DE FIREBASE
      String mensajeEspanol;
      switch (e.code) {
        case 'invalid-credential':
          mensajeEspanol = "El correo o la contraseña son incorrectos.";
          break;
        case 'user-not-found':
          mensajeEspanol = "No existe un usuario con este correo.";
          break;
        case 'wrong-password':
          mensajeEspanol = "La contraseña es incorrecta.";
          break;
        case 'email-already-in-use':
          mensajeEspanol = "Este correo ya está registrado en otra cuenta.";
          break;
        case 'weak-password':
          mensajeEspanol = "La contraseña debe tener al menos 6 caracteres.";
          break;
        case 'network-request-failed':
          mensajeEspanol = "Error de conexión. Revisa tu internet.";
          break;
        case 'invalid-email':
          mensajeEspanol = "El formato del correo no es válido.";
          break;
        default:
          mensajeEspanol = "Ocurrió un error: ${e.message}";
      }
      _mostrarMensaje(mensajeEspanol, Colors.red);
    } catch (e) {
      _mostrarMensaje("Error inesperado. Inténtalo más tarde.", Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the landing page
          },
        ),
      ),
      backgroundColor: const Color(0xFFF2F4F7),
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 50),

                  // Logo de la SDI
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(35),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/sdi.assets.jpg',
                      width: 75,
                      height: 75,
                    ),
                  ),

                  const SizedBox(height: 25),
                  const Text(
                    'BookSwap',
                    style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Intercambio de Material Académico',
                    style: TextStyle(color: Colors.black45, fontSize: 16),
                  ),
                  const SizedBox(height: 40),

                  // TARJETA BLANCA DE FORMULARIO
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(45),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Selector de Pestañas
                        Row(
                          children: [
                            _buildTab("Iniciar Sesión", true),
                            _buildTab("Registrarse", false),
                          ],
                        ),
                        const SizedBox(height: 35),

                        const Text(
                          'Correo Institucional',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            hintText: 'usuario@correo.unimet.edu.ve',
                            prefixIcon: const Icon(Icons.email_outlined),
                            filled: true,
                            fillColor: const Color(0xFFF3F4F6),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 8, left: 5),
                          child: Text(
                            'Usa tu correo institucional verificado',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black38,
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),

                        const Text(
                          'Contraseña',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: passwordController,
                          obscureText: !isPasswordVisible, // Toggle visibility
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  isPasswordVisible = !isPasswordVisible;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF3F4F6),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 35),

                        // Botón Continuar
                        ElevatedButton(
                          onPressed: autenticar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1976D2),
                            minimumSize: const Size(double.infinity, 62),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            isLogin ? 'Iniciar Sesión' : 'Registrarse',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),
                        if (isLogin)
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPasswordScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                '¿Olvidaste tu contraseña?',
                                style: TextStyle(
                                  color: Color(0xFF1976D2),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),

                  // FOOTER DE SEGURIDAD
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.lock_outline, size: 16, color: Colors.black38),
                      Text(
                        ' Protección de datos garantizada',
                        style: TextStyle(color: Colors.black38, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(color: Colors.black38, fontSize: 11),
                        children: [
                          TextSpan(text: 'Al continuar, aceptas los '),
                          TextSpan(
                            text: 'Términos de Servicio',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          TextSpan(text: ' y '),
                          TextSpan(
                            text: 'Política de Privacidad',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget para las pestañas de selección
  Widget _buildTab(String label, bool tabLogin) {
    bool active = isLogin == tabLogin;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => isLogin = tabLogin),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF1976D2) : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
