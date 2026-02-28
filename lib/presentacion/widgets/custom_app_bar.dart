import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/cubits/profile_cubit.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      title: Row(
        children: [
          ClipOval(
            child: Image.asset(
              'assets/sdi.assets.jpg',
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 8),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "BookSwap",
                style: TextStyle(
                  color: Color(0xFF003870),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                "Sistema de Intercambio Académico",
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
      actions: [
        _navItem(context, Icons.home, "Inicio", false, () {
          final state = context.read<ProfileCubit>().state;
          if (state is ProfileLoaded && state.userData['rol'] == 'Admin') {
            Navigator.pushNamed(context, '/admin_home');
          } else {
            Navigator.pushNamed(context, '/home');
          }
        }),
        _navItem(context, Icons.search, "Buscar", false, () {}),
        _navItem(context, Icons.add_circle_outline, "Publicar", false, () {}),
        _navItem(context, Icons.person_outline, "Perfil", false, () {
          Navigator.pushNamed(context, '/perfil');
        }),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _navItem(BuildContext context, IconData icon, String label, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: active ? const Color(0xFF003870) : Colors.black87, size: 24),
            Text(label, style: TextStyle(color: active ? const Color(0xFF003870) : Colors.black87, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);
}