import 'package:flutter/material.dart';

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
          const Text(
            'BookSwap',
            style: TextStyle(
              color: Color(0xFF1976D2),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.home, color: Color(0xFF1976D2)),
          onPressed: () {}, // Sin funcionalidad por ahora
        ),
        IconButton(
          icon: const Icon(Icons.search, color: Color(0xFF1976D2)),
          onPressed: () {}, // Sin funcionalidad por ahora
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, color: Color(0xFF1976D2)),
          onPressed: () {}, // Sin funcionalidad por ahora
        ),
        IconButton(
          icon: const Icon(Icons.person_outline, color: Color(0xFF1976D2)),
          onPressed: () {}, // Sin funcionalidad por ahora
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
