import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/cubits/search_cubit.dart';
import '../widgets/custom_app_bar.dart';

// 1. Modelo de datos (Data)
// Esta lista centraliza la información para que sea fácil de mantener o conectar a Firebase luego.
final List<Map<String, String>> libros = [
  {
    'titulo': 'Cálculo: Una Variable',
    'autor': 'James Stewart',
    'precio': '45.00',
    'categoria': 'MATEMÁTICAS',
    'imagen': 'assets/calculo.jpg',
    'vendedor': 'María González',
    'carrera': 'Ingeniería Civil',
    'iniciales': 'MG',
    'descripcion':
        'Libro en excelente estado, edición 8va. Incluye todos los capítulos sin marcas ni subrayados. Perfecto para cursos de Cálculo I y II.',
  },
  {
    'titulo': 'Física Universitaria',
    'autor': 'Sears & Zemansky',
    'precio': '50.00',
    'categoria': 'FÍSICA',
    'imagen': 'assets/fisica.jpg',
    'vendedor': 'Ricardo Pérez',
    'carrera': 'Ingeniería de Sistemas',
    'iniciales': 'RP',
    'descripcion':
        'Casi nuevo, incluye el solucionario impreso. Muy útil para los laboratorios de Física I.',
  },
  {
    'titulo': 'Física Universitaria',
    'autor': 'Sears & Zemansky',
    'precio': '50.00',
    'categoria': 'FÍSICA',
    'imagen': 'assets/fisica.jpg',
    'vendedor': 'Ricardo Pérez',
    'carrera': 'Ingeniería de Sistemas',
    'iniciales': 'RP',
    'descripcion':
        'Casi nuevo, incluye el solucionario impreso. Muy útil para los laboratorios de Física I.',
  },
  {
    'titulo': 'Física Universitaria',
    'autor': 'Sears & Zemansky',
    'precio': '50.00',
    'categoria': 'FÍSICA',
    'imagen': 'assets/fisica.jpg',
    'vendedor': 'Ricardo Pérez',
    'carrera': 'Ingeniería de Sistemas',
    'iniciales': 'RP',
    'descripcion':
        'Casi nuevo, incluye el solucionario impreso. Muy útil para los laboratorios de Física I.',
  },
  // Puedes añadir más mapas aquí y el Grid se actualizará solo...
];

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
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
                  if (state is SearchLoaded) {
                    if (state.results.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('No se encontraron publicaciones.'),
                            SizedBox(height: 8),
                            Text(
                              'Esto puede deberse a un problema de permisos en Firebase.',
                              style: TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 24,
                            childAspectRatio: 0.68,
                          ),
                      itemCount: state.results.length,
                      itemBuilder: (context, index) {
                        final doc = state.results[index];
                        final data = doc.data() as Map<String, dynamic>;
                        return _buildBookCard(context, data);
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookCard(BuildContext context, Map<String, dynamic> data) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: isHovered
                ? (Matrix4.identity()..translate(0, -5, 0))
                : Matrix4.identity(),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isHovered
                      ? Colors.black.withOpacity(0.15)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: isHovered ? 15 : 10,
                  spreadRadius: isHovered ? 4 : 2,
                ),
              ],
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/detalle_libro',
                  arguments: {
                    'titulo': data['titulo'] ?? 'Sin título',
                    'autor': data['autor'] ?? '',
                    'materia': data['materia'] ?? 'Sin materia',
                    'precio': data['precio']?.toString() ?? '0.00',
                    'descripcion': data['descripcion'] ?? 'Sin descripción',
                    'imagen':
                        data['imageUrl'] ??
                        'assets/images/book_placeholder.png',
                    'vendedor': data['vendedor'] ?? 'Vendedor Anónimo',
                    'carrera': data['carrera'] ?? 'Estudiante',
                    'iniciales': data['iniciales'] ?? 'UN',
                    'userId': data['userId'] ?? '', // ID del vendedor
                    'rol': data['rol'] ?? 'Estudiante', // Rol del vendedor
                    'tipoTransaccion':
                        data['tipoTransaccion'] ?? data['tipo'] ?? 'Venta',
                  },
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          child: Container(
                            width: double.infinity,
                            color: Colors.grey[100],
                            child: data['imageUrl'] != null
                                ? Image.network(
                                    data['imageUrl'],
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Center(
                                              child: Icon(
                                                Icons.book,
                                                size: 40,
                                                color: Colors.grey,
                                              ),
                                            ),
                                  )
                                : const Center(
                                    child: Icon(
                                      Icons.book,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  ),
                          ),
                        ),
                        // Badge (Venta / Intercambio)
                        Positioned(
                          top: 15,
                          left: 15,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (data['tipoTransaccion'] ?? data['tipo']) ==
                                      'Intercambio'
                                  ? const Color(0xFF4CAF50).withOpacity(0.9)
                                  : const Color(0xFF1976D2).withOpacity(0.9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              (data['tipoTransaccion'] ??
                                      data['tipo'] ??
                                      'Venta')
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        // Botón de Like con Hover
                        Positioned(
                          top: 15,
                          right: 15,
                          child: _HoverIconButton(
                            icon: Icons.favorite_border,
                            activeIcon: Icons.favorite,
                            activeColor: Colors.red,
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (data['materia'] ?? 'Sin materia').toUpperCase(),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data['titulo'] ?? 'Sin título',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          data['autor'] ?? 'Sin autor',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              (data['tipoTransaccion'] ?? data['tipo']) ==
                                      'Intercambio'
                                  ? 'Trueque'
                                  : "\$ ${data['precio']?.toString() ?? '0.00'}",
                              style: TextStyle(
                                color:
                                    (data['tipoTransaccion'] ?? data['tipo']) ==
                                        'Intercambio'
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFF1976D2),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Campus',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Widget auxiliar para los botones de icono con efecto hover
class _HoverIconButton extends StatefulWidget {
  final IconData icon;
  final IconData? activeIcon;
  final Color? activeColor;
  final VoidCallback onPressed;

  const _HoverIconButton({
    required this.icon,
    required this.onPressed,
    this.activeIcon,
    this.activeColor,
  });

  @override
  State<_HoverIconButton> createState() => _HoverIconButtonState();
}

class _HoverIconButtonState extends State<_HoverIconButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          setState(() => _isPressed = !_isPressed);
          widget.onPressed();
        },
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
            _isPressed && widget.activeIcon != null
                ? widget.activeIcon
                : widget.icon,
            size: 20,
            color: _isPressed && widget.activeColor != null
                ? widget.activeColor
                : (_isHovered ? Colors.black87 : Colors.grey[700]),
          ),
        ),
      ),
    );
  }
}
