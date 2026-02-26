import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/cubits/auth_cubit.dart';
import '../../domain/entities/auth_state.dart';
import 'forgot_password_screen.dart';
import 'home_page.dart';
import 'admin_home_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController cedulaController = TextEditingController(); // <-- NUEVO
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController departamentoController = TextEditingController(); 
  
  String rolSeleccionado = 'Estudiante';
  String? carreraSeleccionada; 
  bool isLogin = true;
  bool isPasswordVisible = false;

  final List<String> opcionesCarrera = [
    'Ingeniería Civil',
    'Ingeniería Eléctrica',
    'Ingeniería Mecánica',
    'Ingeniería de Producción',
    'Ingeniería Química',
    'Ingeniería de Sistemas',
    'TSU en Desarrollo de Sistemas Inteligentes',
    'Ciencias Administrativas',
    'Contaduría Pública',
    'Economía Empresarial',
    'Turismo Sostenible',
    'Derecho',
    'Estudios Liberales',
    'Estudios Internacionales',
    'Comunicación Social y Empresarial',
    'Idiomas Modernos',
    'Educación',
    'Psicología',
    'Matemáticas Industriales',
  ];

  void _mostrarMensaje(String texto, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String formatearNombre(String texto) {
    if (texto.isEmpty) return texto;
    return texto.split(' ').map((palabra) {
      if (palabra.isEmpty) return '';
      return palabra[0].toUpperCase() + palabra.substring(1).toLowerCase();
    }).join(' ');
  }

  void autenticar() {
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _mostrarMensaje("Por favor, llena correo y contraseña", Colors.orange);
      return;
    }

    final authCubit = context.read<AuthCubit>();

    if (isLogin) {
      // --- LOGIN ---
      if (!email.endsWith('@correo.unimet.edu.ve') && !email.endsWith('@unimet.edu.ve')) {
        _mostrarMensaje("Usa un correo válido de la Unimet", Colors.red);
        return;
      }
      authCubit.login(email, password);

    } else {
      // --- REGISTRO ---
      String nombreRaw = nombreController.text.trim();
      final cedula = cedulaController.text.trim(); // <-- CAPTURAMOS CÉDULA
      final telefono = telefonoController.text.trim();
      
      final carreraODepartamento = rolSeleccionado == 'Estudiante' 
          ? (carreraSeleccionada ?? '') 
          : departamentoController.text.trim();

      if (nombreRaw.isEmpty || cedula.isEmpty || carreraODepartamento.isEmpty || telefono.isEmpty) {
        _mostrarMensaje("Por favor, completa todos tus datos personales", Colors.orange);
        return;
      }

      if (nombreRaw.split(' ').length < 2) {
        _mostrarMensaje("Por favor, ingresa tu nombre y apellido", Colors.orange);
        return;
      }

      String nombreFormateado = formatearNombre(nombreRaw);

      if (rolSeleccionado == 'Estudiante' && !email.endsWith('@correo.unimet.edu.ve')) {
        _mostrarMensaje("Los estudiantes deben usar @correo.unimet.edu.ve", Colors.red);
        return;
      }
      if (rolSeleccionado == 'Profesor' && !email.endsWith('@unimet.edu.ve')) {
        _mostrarMensaje("Los profesores deben usar @unimet.edu.ve", Colors.red);
        return;
      }

      authCubit.register(
        email: email,
        password: password,
        rol: rolSeleccionado,
        nombre: nombreFormateado,
        cedula: cedula, // <-- ENVIAMOS LA CÉDULA AL CUBIT
        carrera: carreraODepartamento,
        telefono: telefono,
      );
    }
  }

  void _navigateToForgotPasswordScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nombreController.dispose();
    cedulaController.dispose(); // <-- LIMPIAMOS MEMORIA
    telefonoController.dispose();
    departamentoController.dispose();
    super.dispose();
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
          onPressed: () => Navigator.pop(context),
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
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(35),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20),
                      ],
                    ),
                    child: Image.asset('assets/sdi.assets.jpg', width: 75, height: 75),
                  ),

                  const SizedBox(height: 25),
                  const Text('BookSwap', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
                  const Text('Intercambio de Material Académico', style: TextStyle(color: Colors.black45, fontSize: 16)),
                  const SizedBox(height: 30),

                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(45)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildTab("Iniciar Sesión", true),
                            _buildTab("Registrarse", false),
                          ],
                        ),
                        const SizedBox(height: 35),

                        if (!isLogin) ...[
                          const Text('¿Qué eres?', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            value: rolSeleccionado,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.person_outline),
                              filled: true,
                              fillColor: const Color(0xFFF3F4F6),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                            ),
                            items: ['Estudiante', 'Profesor'].map((String rol) => DropdownMenuItem(value: rol, child: Text(rol))).toList(),
                            onChanged: (String? nuevoValor) {
                              setState(() {
                                rolSeleccionado = nuevoValor!;
                                emailController.clear();
                              });
                            },
                          ),
                          const SizedBox(height: 20),

                          const Text('Nombre y Apellido', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          _buildCustomTextField(
                            controller: nombreController, 
                            hint: 'Juan Pérez', 
                            icon: Icons.badge_outlined,
                            textCapitalization: TextCapitalization.words,
                          ),
                          const SizedBox(height: 20),

                          // --- NUEVO CAMPO DE CÉDULA O CARNET ---
                          const Text('Cédula o Carnet', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          _buildCustomTextField(
                            controller: cedulaController, 
                            hint: 'Ej. 28123456', 
                            icon: Icons.credit_card_outlined,
                            keyboardType: TextInputType.number, // <-- Muestra el teclado numérico
                          ),
                          const SizedBox(height: 20),

                          if (rolSeleccionado == 'Estudiante') ...[
                            const Text('Carrera', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              value: carreraSeleccionada,
                              isExpanded: true,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.school_outlined),
                                filled: true,
                                fillColor: const Color(0xFFF3F4F6),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                                hintText: 'Selecciona tu carrera',
                              ),
                              items: opcionesCarrera.map((String carrera) => DropdownMenuItem(value: carrera, child: Text(carrera, overflow: TextOverflow.ellipsis))).toList(),
                              onChanged: (String? nuevoValor) => setState(() => carreraSeleccionada = nuevoValor),
                            ),
                          ] else ...[
                            const Text('Departamento', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            _buildCustomTextField(
                              controller: departamentoController,
                              hint: 'Ej. Matemáticas',
                              icon: Icons.business_center_outlined,
                              textCapitalization: TextCapitalization.words,
                            ),
                          ],
                          const SizedBox(height: 20),

                          const Text('Teléfono', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          _buildCustomTextField(
                            controller: telefonoController,
                            hint: '0412 1234567',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 20),
                        ],

                        const Text('Correo Institucional', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: !isLogin && rolSeleccionado == 'Profesor' ? 'usuario@unimet.edu.ve' : 'usuario@correo.unimet.edu.ve',
                            prefixIcon: const Icon(Icons.email_outlined),
                            filled: true,
                            fillColor: const Color(0xFFF3F4F6),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                          ),
                        ),
                        if (isLogin)
                          const Padding(
                            padding: EdgeInsets.only(top: 8, left: 5),
                            child: Text('Usa tu correo institucional verificado', style: TextStyle(fontSize: 12, color: Colors.black38)),
                          ),
                        const SizedBox(height: 25),

                        const Text('Contraseña', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        TextField(
                          controller: passwordController,
                          obscureText: !isPasswordVisible,
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                              onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF3F4F6),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 35),

                        BlocConsumer<AuthCubit, AuthState>(
                          listener: (context, state) {
                            if (state is AuthError) {
                              _mostrarMensaje(state.message, Colors.red);
                            } else if (state is AuthAuthenticated) {
                              if (isLogin) {
                                _mostrarMensaje("Inicio de sesión exitoso", Colors.green);
                                if (emailController.text.trim().toLowerCase() == 'admin@correo.unimet.edu.ve') {
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminHomePage()));
                                } else {
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
                                }
                              }
                            } else if (state is AuthUnauthenticated && !isLogin) {
                              _mostrarMensaje("Registro exitoso. Ahora inicia sesión.", Colors.green);
                              setState(() {
                                isLogin = true;
                                passwordController.clear();
                                nombreController.clear();
                                cedulaController.clear(); // <-- LO LIMPIAMOS PARA EL SIGUIENTE REGISTRO
                                telefonoController.clear();
                                departamentoController.clear();
                                carreraSeleccionada = null;
                              });
                            }
                          },
                          builder: (context, state) {
                            if (state is AuthLoading) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            return ElevatedButton(
                              onPressed: autenticar,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1976D2),
                                minimumSize: const Size(double.infinity, 62),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                              child: Text(
                                isLogin ? 'Iniciar Sesión' : 'Registrarse',
                                style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 25),
                        if (isLogin)
                          Center(
                            child: TextButton(
                              onPressed: _navigateToForgotPasswordScreen,
                              child: const Text('¿Olvidaste tu contraseña?', style: TextStyle(color: Color(0xFF1976D2), fontWeight: FontWeight.w600)),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.lock_outline, size: 16, color: Colors.black38),
                      Text(' Protección de datos garantizada', style: TextStyle(color: Colors.black38, fontSize: 13)),
                    ],
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

  Widget _buildCustomTextField({
    required TextEditingController controller, 
    required String hint, 
    required IconData icon, 
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildTab(String label, bool tabLogin) {
    bool active = isLogin == tabLogin;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          isLogin = tabLogin;
          emailController.clear();
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF1976D2) : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Center(
            child: Text(label, style: TextStyle(color: active ? Colors.white : Colors.black54, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}