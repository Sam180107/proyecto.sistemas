import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:unimet_marketplace/firebase_options.dart';

// Importa tus páginas - Verifica que las rutas de archivos sean correctas
import 'presentacion/landing_page.dart';
import 'presentacion/home_page.dart';
import 'presentacion/perfil_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BookSwap Unimet',
      // Definimos las rutas exactas para que Navigator las encuentre
      initialRoute: '/landing', 
      routes: {
        '/landing': (context) => const LandingPage(),
        '/home': (context) => const HomePage(),
        '/perfil': (context) => const PerfilPage(),
      },
    );
  }
}