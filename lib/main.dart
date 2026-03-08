import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unimet_marketplace/firebase_options.dart';

// Repositorios
import 'package:unimet_marketplace/data/repositories/auth_repository.dart';
import 'package:unimet_marketplace/data/repositories/order_repository.dart';

// Cubits
import 'package:unimet_marketplace/domain/cubits/auth_cubit.dart';
import 'package:unimet_marketplace/domain/cubits/profile_cubit.dart';
import 'package:unimet_marketplace/domain/cubits/rating_cubit.dart';
import 'package:unimet_marketplace/domain/cubits/search_cubit.dart';
import 'package:unimet_marketplace/domain/cubits/order_cubit.dart';
import 'package:unimet_marketplace/domain/cubits/cart_cubit.dart';
import 'package:unimet_marketplace/domain/cubits/notification_cubit.dart';

// Páginas
import 'package:unimet_marketplace/presentacion/pages/landing_page.dart';
import 'package:unimet_marketplace/presentacion/pages/home_page.dart';
import 'package:unimet_marketplace/presentacion/pages/admin_home_page.dart';
import 'package:unimet_marketplace/presentacion/pages/login_screen.dart';
import 'package:unimet_marketplace/presentacion/pages/payment_page.dart';
import 'package:unimet_marketplace/presentacion/pages/perfil_admin_page.dart';
import 'package:unimet_marketplace/presentacion/pages/perfil_page.dart';
import 'package:unimet_marketplace/presentacion/pages/detalle_libro_page.dart';
import 'package:unimet_marketplace/presentacion/pages/cart_page.dart';
import 'package:unimet_marketplace/presentacion/pages/publicar_libro_page.dart';
import 'package:unimet_marketplace/presentacion/pages/orders_page.dart';
import 'package:unimet_marketplace/presentacion/pages/gestion_publicaciones_page.dart';
import 'package:unimet_marketplace/presentacion/pages/gestion_usuarios_page.dart';
import 'package:unimet_marketplace/presentacion/pages/solicitudes_carrera_page.dart';
import 'package:unimet_marketplace/presentacion/pages/gestion_reportes_page.dart';
import 'package:unimet_marketplace/presentacion/pages/notificaciones_page.dart';
import 'package:unimet_marketplace/domain/cubits/cora_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await Supabase.initialize(
      url: 'https://gcwnvqkubwxwkgeazqmc.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdjd252cWt1Ynd4d2tnZWF6cW1jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI4ODg0MzYsImV4cCI6MjA4ODQ2NDQzNn0.Sa69AieyGPTuH0IcFbid5Ezb57-tcguGghDIxJNmdZs',
    );
  } catch (e) {
    debugPrint("Error al inicializar Firebase o Supabase: $e");
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
          BlocProvider(create: (context) => RatingCubit()),
          BlocProvider(create: (context) => SearchCubit()),
          BlocProvider(create: (context) => OrderCubit(OrderRepository())),
          BlocProvider(create: (context) => CartCubit()),
          BlocProvider(create: (context) => NotificationCubit()),
          BlocProvider(create: (context) => CoraCubit()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'BookSwap Unimet',

          theme: ThemeData(
            primaryColor: const Color(0xFF003870),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1E88E5),
            ),
            useMaterial3: true,
          ),

          initialRoute: '/',
          routes: {
            '/': (context) => const LandingPage(),
            '/login': (context) => const LoginScreen(),
            '/home': (context) => const HomePage(),
            '/publicar': (context) => const PublicarLibroPage(),
            '/admin_home': (context) => const AdminHomePage(),
            '/perfil_admin': (context) => const PerfilAdminPage(),
            '/perfil': (context) => const PerfilPage(),
            '/cart': (context) => const CartPage(),
            '/detalle_libro': (context) => const DetalleLibroPage(),
            '/orders': (context) => const OrdersPage(),
            '/payment': (context) => const PaymentPage(),
            '/gestion_publicaciones': (context) =>
                const GestionPublicacionesPage(),
            '/gestion_usuarios': (context) => const GestionUsuariosPage(),
            '/solicitudes_carrera': (context) => const SolicitudesCarreraPage(),
            '/gestion_reportes': (context) => const GestionReportesPage(),
            '/notificaciones': (context) => const NotificacionesPage(),
          },
        ),
      ),
    );
  }
}
