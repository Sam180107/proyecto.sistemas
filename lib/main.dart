import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unimet_marketplace/firebase_options.dart';

// Repositorios
import 'package:unimet_marketplace/data/repositories/auth_repository.dart';

// Cubits
import 'package:unimet_marketplace/domain/cubits/auth_cubit.dart';
import 'package:unimet_marketplace/domain/cubits/profile_cubit.dart';

// Páginas
import 'package:unimet_marketplace/presentacion/pages/landing_page.dart';
import 'package:unimet_marketplace/presentacion/pages/home_page.dart';
import 'package:unimet_marketplace/presentacion/pages/admin_home_page.dart';
import 'package:unimet_marketplace/presentacion/pages/login_screen.dart';
import 'package:unimet_marketplace/presentacion/pages/perfil_admin_page.dart';
import 'package:unimet_marketplace/presentacion/pages/perfil_page.dart';
import 'package:unimet_marketplace/presentacion/pages/detalle_libro_page.dart'; // Importación necesaria

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Inicialización de Firebase con las opciones generadas por FlutterFire CLI
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print("Error al inicializar Firebase: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      // Proveedor del repositorio de autenticación para toda la App
      create: (context) => AuthRepository(),
      child: MultiBlocProvider(
        providers: [
          // Gestión del estado de la sesión (Login/Logout)
          BlocProvider(
            create: (context) => AuthCubit(context.read<AuthRepository>()),
          ),
          // Gestión del estado del perfil del usuario
          BlocProvider(
            create: (context) => ProfileCubit(), 
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'BookSwap Unimet',
          
          // Tema de la aplicación (opcional, puedes personalizarlo aquí)
          theme: ThemeData(
            primaryColor: const Color(0xFF003870),
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E88E5)),
            useMaterial3: true,
          ),

          // Configuración de rutas
          initialRoute: '/',
          routes: {
            '/': (context) => const LandingPage(),
            '/login': (context) => const LoginScreen(),
            '/home': (context) => const HomePage(),
            '/publicar': (context) => const PublicarLibroPage(),
            '/admin_home': (context) => const AdminHomePage(),
            '/perfil_admin': (context) => const PerfilAdminPage(),
            '/perfil': (context) => const PerfilPage(),
            '/detalle_libro': (context) => const DetalleLibroPage(), // Ruta para ver el libro a detalle
          },
        ),
      ),
    );
  }
}