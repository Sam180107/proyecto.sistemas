import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/cubits/search_cubit.dart';
import '../widgets/custom_app_bar.dart';
import 'product_detail_page.dart';

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
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 24,
                              childAspectRatio: 0.68,
                            ),
                            itemCount: state.results.length,
                            itemBuilder: (context, index) {
                              final doc = state.results[index];
                              final data = doc.data() as Map<String, dynamic>;
                              // Add the document ID to the data map
                              data['id'] = doc.id;
                              return _buildBookCard(context, data);
                            },
                          );
                        },
                      );
                    } else if (state is SearchLoaded) { // Check for empty results explicitly
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('No se encontraron publicaciones.'),
                            SizedBox(height: 8),
                            Text(
                              'Intenta con otros filtros o revisa los permisos en Firebase.',
                              style: TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink(); // Default fallback
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookCard(BuildContext context, Map<String, dynamic> data) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(productData: data),
          ),
        );
      },
      child: Container(
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
                    color: Colors.grey[200],
                    child: data['imageUrl'] != null || data['imagen'] != null
                        ? Image.network(
                            data['imageUrl'] ?? data['imagen'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.book,
                                    size: 40, color: Colors.grey),
                          )
                        : const Center(
                            child:
                                Icon(Icons.book, size: 40, color: Colors.grey),
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
                      data['tipoTransaccion'] ?? 'N/A',
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
                        fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    data['autor'] ?? 'Sin autor',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Builder(
                    builder: (context) {
                      final rawPrice = data['precio'];
                      String price = '0.00';
                      if (rawPrice != null) {
                        if (rawPrice is num) {
                          price = rawPrice.toStringAsFixed(2);
                        } else if (rawPrice is String) {
                          price = double.tryParse(rawPrice)?.toStringAsFixed(2) ?? rawPrice;
                        }
                      }
                      return Text(
                        "\$ $price",
                        style: const TextStyle(
                          color: Color(0xFF003870),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
