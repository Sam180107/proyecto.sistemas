import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unimet_marketplace/firebase_options.dart';
import 'package:unimet_marketplace/data/repositories/auth_repository.dart';
import 'package:unimet_marketplace/domain/cubits/auth_cubit.dart';
import 'package:unimet_marketplace/presentacion/pages/landing_page.dart';
import 'package:unimet_marketplace/presentacion/pages/home_page.dart';
import 'package:unimet_marketplace/presentacion/perfil_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => AuthRepository(),
      child: BlocProvider(
        create: (context) => AuthCubit(context.read<AuthRepository>()),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'BookSwap Unimet',
          initialRoute: '/landing',
          routes: {
            '/landing': (context) => const LandingPage(),
            '/home': (context) => const HomePage(),
            '/perfil': (context) => const PerfilPage(),
          },
        ),
      ),
    );
  }
}
