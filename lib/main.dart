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
import 'package:unimet_marketplace/domain/cubits/rating_cubit.dart';
import 'package:unimet_marketplace/domain/cubits/search_cubit.dart';

// Páginas
import 'package:unimet_marketplace/presentacion/pages/landing_page.dart';
import 'package:unimet_marketplace/presentacion/pages/home_page.dart';
import 'package:unimet_marketplace/presentacion/pages/admin_home_page.dart';
import 'package:unimet_marketplace/presentacion/pages/login_screen.dart';
import 'package:unimet_marketplace/presentacion/pages/perfil_admin_page.dart';
import 'package:unimet_marketplace/presentacion/pages/perfil_page.dart';
import 'package:unimet_marketplace/presentacion/pages/detalle_libro_page.dart';
import 'package:unimet_marketplace/presentacion/pages/publicar_libro_page.dart';
import 'package:unimet_marketplace/presentacion/pages/gestion_publicaciones_page.dart';
import 'package:unimet_marketplace/presentacion/pages/gestion_usuarios_page.dart';
import 'package:unimet_marketplace/presentacion/pages/solicitudes_carrera_page.dart';
import 'package:unimet_marketplace/presentacion/pages/gestion_reportes_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Inicialización de Firebase con las opciones generadas por FlutterFire CLI
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Inicialización de Supabase
    await Supabase.initialize(
      url: 'https://gcwnvqkubwxwkgeazqmc.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdjd252cWt1Ynd4d2tnZWF6cW1jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI4ODg0MzYsImV4cCI6MjA4ODQ2NDQzNn0.Sa69AieyGPTuH0IcFbid5Ezb57-tcguGghDIxJNmdZs',
    );
  } catch (e) {
    print("Error al inicializar Firebase o Supabase: $e");
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
          // Gestión del estado de valoraciones
          BlocProvider(
            create: (context) => RatingCubit(),
          ),
          // SearchCubit global para que la búsqueda funcione en toda la app
          BlocProvider(
            create: (context) => SearchCubit(),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'BookSwap Unimet',
          
          // Tema de la aplicación
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
            '/detalle_libro': (context) => const DetalleLibroPage(),
            '/gestion_publicaciones': (context) => const GestionPublicacionesPage(),
            '/gestion_usuarios': (context) => const GestionUsuariosPage(),
            '/solicitudes_carrera': (context) => const SolicitudesCarreraPage(),
            '/gestion_reportes': (context) => const GestionReportesPage(),
          },
        ),
      ),
    );
  }
}