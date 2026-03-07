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
    'descripcion': 'Libro en excelente estado, edición 8va. Incluye todos los capítulos sin marcas ni subrayados. Perfecto para cursos de Cálculo I y II.',
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
    'descripcion': 'Casi nuevo, incluye el solucionario impreso. Muy útil para los laboratorios de Física I.',
  },
  // Puedes añadir más mapas aquí y el Grid se actualizará solo
];

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchCubit(),
      child: Scaffold(
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
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.65,
                            ),
                        itemCount: state.results.length,
                        itemBuilder: (context, index) {
                          final doc = state.results[index];
                          final data = doc.data() as Map<String, dynamic>;
                          return _buildBookCard(data);
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
      ),
    );
  }

  Widget _buildBookCard(Map<String, dynamic> data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
                child: Container(
                  height: 140,
                  width: double.infinity,
                  color: Colors.grey[100],
                  child: data['imageUrl'] != null
                      ? Image.network(
                          data['imageUrl'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                                child: Icon(
                                  Icons.book,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              ),
                        )
                      : const Center(
                          child: Icon(Icons.book, size: 40, color: Colors.grey),
                        ),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF003870),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    data['tipoTransaccion'] ?? data['tipo'] ?? 'N/A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (data['materia'] ?? 'Sin materia').toUpperCase(),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data['titulo'] ?? 'Sin título',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  data['autor'] ?? 'Sin autor',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  "\$ ${data['precio']?.toStringAsFixed(2) ?? '0.00'}",
                  style: const TextStyle(
                    color: Color(0xFF003870),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
