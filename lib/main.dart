import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    print("Error Firebase: $e");
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
          BlocProvider(
            create: (context) => ProfileCubit(), 
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'BookSwap Unimet',
          initialRoute: '/',
          routes: {
            '/': (context) => const LandingPage(),
            '/login': (context) => const LoginScreen(),
            '/home': (context) => const HomePage(),
            '/admin_home': (context) => const AdminHomePage(),
            '/perfil_admin': (context) => const PerfilAdminPage(),
            '/perfil': (context) => const PerfilPage(), // Ruta para usuarios normales
          },
        ),
      ),
    );
  }
}
