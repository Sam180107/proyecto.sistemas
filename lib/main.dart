import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unimet_marketplace/firebase_options.dart';

import 'package:unimet_marketplace/data/repositories/auth_repository.dart';
import 'package:unimet_marketplace/domain/cubits/auth_cubit.dart';
import 'package:unimet_marketplace/domain/cubits/profile_cubit.dart';

import 'package:unimet_marketplace/presentacion/pages/landing_page.dart';
import 'package:unimet_marketplace/presentacion/pages/home_page.dart';
import 'package:unimet_marketplace/presentacion/pages/admin_home_page.dart';
import 'package:unimet_marketplace/presentacion/pages/login_screen.dart';
import 'package:unimet_marketplace/presentacion/pages/perfil_admin_page.dart';
import 'package:unimet_marketplace/presentacion/pages/perfil_page.dart'; // Asegúrate de que esta ruta sea correcta
import 'package:unimet_marketplace/presentacion/pages/publicar_libro_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Inicialización de Supabase para el almacenamiento de imágenes
    await Supabase.initialize(
      url: 'https://gcwnvqkubwxwkgeazqmc.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdjd252cWt1Ynd4d2tnZWF6cW1jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI4ODg0MzYsImV4cCI6MjA4ODQ2NDQzNn0.Sa69AieyGPTuH0IcFbid5Ezb57-tcguGghDIxJNmdZs',
    );
  } catch (e) {
    print("Error inicialización: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => AuthRepository(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthCubit(context.read<AuthRepository>()),
          ),
          BlocProvider(create: (context) => ProfileCubit()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'BookSwap Unimet',
          initialRoute: '/',
          routes: {
            '/': (context) => const LandingPage(),
            '/login': (context) => const LoginScreen(),
            '/home': (context) => const HomePage(),
            '/publicar': (context) => const PublicarLibroPage(),
            '/admin_home': (context) => const AdminHomePage(),
            '/perfil_admin': (context) => const PerfilAdminPage(),
            '/perfil': (context) =>
                const PerfilPage(), // Ruta para usuarios normales
          },
        ),
      ),
    );
  }
}
