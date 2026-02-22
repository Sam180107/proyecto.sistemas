import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/auth_cubit.dart';
import '../logic/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLogin = true;

  void autenticar() {
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) return;

    if (isLogin) {
      context.read<AuthCubit>().login(email, password);
    } else {
      context.read<AuthCubit>().register(email, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 60),
                const Text(
                  "BookSwap",
                  style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _buildTab("Iniciar Sesión", true),
                          _buildTab("Registrarse", false),
                        ],
                      ),
                      const SizedBox(height: 30),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText:
                              "usuario@correo.unimet.edu.ve",
                          filled: true,
                          fillColor:
                              const Color(0xFFF3F4F6),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "••••••••",
                          filled: true,
                          fillColor:
                              const Color(0xFFF3F4F6),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          if (state is AuthLoading) {
                            return const CircularProgressIndicator();
                          }

                          return ElevatedButton(
                            onPressed: autenticar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF1976D2),
                              minimumSize:
                                  const Size(double.infinity, 60),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              isLogin
                                  ? "Iniciar Sesión"
                                  : "Registrarse",
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String label, bool loginTab) {
    final active = isLogin == loginTab;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => isLogin = loginTab),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFF1976D2)
                : Colors.transparent,
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