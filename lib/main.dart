import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Estas rutas ahora son relativas a la carpeta lib/
import 'firebase_options.dart';
import 'data/auth_repository.dart';
import 'logic/auth_cubit.dart';
import 'presentacion/landing_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase con el archivo que generó el CLI
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Esto quita el error de 'key' que tenías antes

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => AuthRepository(),
      child: BlocProvider(
        create: (context) => AuthCubit(context.read<AuthRepository>()),
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'BookSwap Unimet',
          home: LandingPage(), // Empezamos con la Landing Page
        ),
      ),
    );
  }
}
