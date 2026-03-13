import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/cubits/search_cubit.dart';
import '../widgets/custom_app_bar.dart';
import 'package:unimet_marketplace/domain/cubits/cora_cubit.dart';
import 'package:share_plus/share_plus.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchCubit(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F4F7),
        appBar: const CustomAppBar(),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Explorar Material Académico',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Encuentra libros y material de estudio para tus cursos',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 20),
                BlocBuilder<SearchCubit, SearchState>(
                  builder: (context, state) {
                    if (state is SearchInitial || state is SearchLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is SearchError) {
                      return Center(child: Text(state.message));
                    }
                    if (state is SearchLoaded && state.results.isNotEmpty) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          int crossAxisCount = 4;
                          if (constraints.maxWidth < 600) {
                            crossAxisCount = 2;
                          } else if (constraints.maxWidth < 900) {
                            crossAxisCount = 3;
                          }

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.65,
                                ),
                            itemCount: state.results.length,
                            itemBuilder: (context, index) {
                              final doc =
                                  state.results[index] as DocumentSnapshot;
                              final data = doc.data() as Map<String, dynamic>;
                              final bookData = Map<String, dynamic>.from(data);
                              bookData['id'] = doc.id;
                              return _BookCard(bookData: bookData);
                            },
                          );
                        },
                      );
                    }
                    return const Center(
                      child: Text('No se encontraron resultados'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
            Positioned(
              top: 10,
              right: 16,
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                onPressed: () => Navigator.pushNamed(context, '/favorites'),
                child: const Icon(Icons.favorite, color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookCard extends StatefulWidget {
  final Map<String, dynamic> bookData;

  const _BookCard({required this.bookData});

  @override
  State<_BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<_BookCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final String libroId = widget.bookData['id'] ?? '';
    final String? imageUrl =
        widget.bookData['imageUrl'] ?? widget.bookData['imagen'];

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/detalle_libro',
              arguments: widget.bookData,
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(_isHovered ? 0.15 : 0.05),
                  blurRadius: _isHovered ? 20 : 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 12,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          child:
                              (imageUrl != null &&
                                  imageUrl
                                      .toString()
                                      .startsWith('http'))
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Center(
                                        child: Icon(Icons.broken_image),
                                      ),
                                )
                              : (imageUrl != null)
                              ? Image.asset(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Center(
                                        child: Icon(Icons.broken_image),
                                      ),
                                )
                              : const Center(
                                  child: Icon(Icons.image_not_supported),
                                ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Row(
                          children: [
                            _HoverIconButton(
                              icon: Icons.share_outlined,
                              onPressed: () {
                                final titulo =
                                    widget.bookData['titulo'] ??
                                    'Material Académico';
                                final precio = widget.bookData['precio'] ?? '0';
                                Share.share(
                                  '¡Mira este libro en BookSwap! "$titulo" por $precio.',
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('usuarios')
                                  .doc(FirebaseAuth.instance.currentUser?.uid)
                                  .collection('favoritos')
                                  .doc(libroId)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                bool esFavorito =
                                    snapshot.hasData && snapshot.data!.exists;
                                return _HoverIconButton(
                                  icon: esFavorito
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  isSelected: esFavorito,
                                  activeColor: Colors.red,
                                  onPressed: () {
                                    context.read<CoraCubit>().toggleFavorito(
                                      libroId,
                                      esFavorito,
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 8,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14.0,
                      vertical: 12.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.bookData['categoria'] ?? 'CATEGORIA',
                          style: const TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E88E5),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.bookData['titulo'] ?? 'Sin título',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                            color: Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$ ${widget.bookData['precio'] ?? '0'}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF003870),
                              ),
                            ),
                          ],
                        ),

                      ],
                    ),
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

class _HoverIconButton extends StatefulWidget {
  final IconData icon;
  final IconData? activeIcon;
  final VoidCallback onPressed;
  final bool isSelected;
  final Color? activeColor;

  const _HoverIconButton({
    required this.icon,
    required this.onPressed,
    this.activeIcon,
    this.isSelected = false,
    this.activeColor,
  });

  @override
  State<_HoverIconButton> createState() => _HoverIconButtonState();
}

class _HoverIconButtonState extends State<_HoverIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _isHovered ? Colors.white : Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: Icon(
            widget.isSelected
                ? (widget.activeIcon ?? widget.icon)
                : widget.icon,
            size: 20,
            color: widget.isSelected
                ? (widget.activeColor ?? Colors.red)
                : (_isHovered ? Colors.black87 : Colors.grey[700]),
          ),
        ),
      ),
    );
  }
}
