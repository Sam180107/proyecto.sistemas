import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unimet_marketplace/domain/cubits/cart_cubit.dart';
import 'package:unimet_marketplace/domain/cubits/notification_cubit.dart';
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
          isActive: true,
          onTap: () {
            Navigator.pushReplacementNamed(context, '/home');
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
          icon: Icons.receipt_long,
          label: "Intercambios",
          onTap: () {
            Navigator.pushNamed(context, '/orders');
          },
        ),
        Stack(
          children: [
            _HoverNavItem(
              icon: Icons.shopping_cart_outlined,
              label: "Carrito",
              onTap: () {
                Navigator.pushNamed(context, '/cart');
              },
            ),
            BlocBuilder<CartCubit, CartState>(
              builder: (context, state) {
                if (state.itemCount == 0) return const SizedBox.shrink();
                return Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${state.itemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        // Campana de notificaciones
        BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, notifState) {
            final count = notifState.totalUnread;
            return Stack(
              children: [
                _HoverNavItem(
                  icon: Icons.notifications_outlined,
                  label: 'Notificaciones',
                  onTap: () =>
                      Navigator.pushNamed(context, '/notificaciones'),
                ),
                if (count > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                          minWidth: 16, minHeight: 16),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        _HoverNavItem(
          icon: Icons.person_outline,
          label: "Perfil",
          onTap: () {
            final profileState = context.read<ProfileCubit>().state;
            if (profileState is ProfileLoaded &&
                profileState.userData['rol'] == 'Admin') {
              Navigator.pushNamed(context, '/perfil_admin');
            } else {
              Navigator.pushNamed(context, '/perfil');
            }
          },
        ),
        // Botón Dashboard solo visible para Admin
        BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoaded && state.userData['rol'] == 'Admin') {
              return _HoverNavItem(
                icon: Icons.dashboard_outlined,
                label: "Dashboard",
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/admin_home');
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(85);
}

class _HoverNavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _HoverNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
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
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          decoration: BoxDecoration(
            color: widget.isActive
                ? const Color(0xFF003870).withOpacity(0.1)
                : (_isHovering
                      ? Colors.grey.withOpacity(0.1)
                      : Colors.transparent),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: widget.isActive || _isHovering
                    ? const Color(0xFF003870)
                    : Colors.black87,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.isActive || _isHovering
                      ? const Color(0xFF003870)
                      : Colors.black87,
                  fontSize: 16,
                  fontWeight: widget.isActive || _isHovering
                      ? FontWeight.bold
                      : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
