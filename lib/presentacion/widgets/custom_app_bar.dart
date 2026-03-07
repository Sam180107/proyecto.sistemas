import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/cubits/profile_cubit.dart';
import '../../domain/cubits/search_cubit.dart';
import 'search_overlay.dart';

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
        _HoverNavItem(
          icon: Icons.home,
          label: "Inicio",
          onTap: () {
            final state = context.read<ProfileCubit>().state;
            if (state is ProfileLoaded && state.userData['rol'] == 'Admin') {
              Navigator.pushReplacementNamed(context, '/admin_home');
            } else {
              Navigator.pushReplacementNamed(context, '/home');
            }
          },
        ),
        _HoverNavItem(
          icon: Icons.search,
          label: "Buscar",
          onTap: () {
            showDialog(
              context: context,
              builder: (dialogContext) {
                return BlocProvider.value(
                  value: context.read<SearchCubit>(),
                  child: const SearchOverlay(),
                );
              },
            );
          },
        ),
        _HoverNavItem(
          icon: Icons.add_circle_outline,
          label: "Publicar",
          onTap: () {
            Navigator.pushNamed(context, '/publicar');
          },
        ),
        _HoverNavItem(
          icon: Icons.person_outline,
          label: "Perfil",
          onTap: () {
            Navigator.pushNamed(context, '/perfil');
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);
}

class _HoverNavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HoverNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_HoverNavItem> createState() => _HoverNavItemState();
}

class _HoverNavItemState extends State<_HoverNavItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: AnimatedScale(
            scale: _isHovering ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.icon,
                  color: _isHovering ? const Color(0xFF0056b3) : Colors.black87,
                  size: 26,
                ),
                const SizedBox(height: 2),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: _isHovering
                        ? const Color(0xFF0056b3)
                        : Colors.black87,
                    fontSize: 11,
                    fontWeight: _isHovering
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
