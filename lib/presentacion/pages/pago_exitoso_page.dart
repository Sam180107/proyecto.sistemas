import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unimet_marketplace/domain/cubits/rating_cubit.dart';

class PagoExitosoPage extends StatelessWidget {
  const PagoExitosoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // arguments es una lista de mapas con id y nombre del vendedor
    final List<dynamic> rawArguments = (ModalRoute.of(context)?.settings.arguments as List<dynamic>?) ?? [];

    // Filtramos vendedores duplicados basándonos en el ID
    final vendedoresUnicos = [];
    final idsVistos = <String>{};
    for (var v in rawArguments) {
      if (v is Map) {
        final id = v['id']?.toString();
        if (id != null && !idsVistos.contains(id)) {
          idsVistos.add(id);
          vendedoresUnicos.add(v);
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Transacción Completada'),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Quitar la flecha de atrás
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 100,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '¡Pago Completado con Éxito!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF003870),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'El vendedor recibirá una notificación de la venta. Tu orden está ahora marcada como Pagada.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              if (vendedoresUnicos.isNotEmpty) ...[
                const Text(
                  'Por favor, valora a los vendedores:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                ...vendedoresUnicos.map((vendedor) => _buildValoracionCard(context, vendedor['id']!.toString(), vendedor['nombre']?.toString() ?? 'Vendedor')),
              ],
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Limpiar el stack de navegación y volver al home
                    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Volver al Inicio',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValoracionCard(BuildContext context, String vendedorId, String nombreVendedor) {
    return BlocProvider(
      create: (context) => RatingCubit()..cargarValoraciones(vendedorId),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: BlocBuilder<RatingCubit, RatingState>(
            builder: (context, state) {
              if (state is RatingLoaded && state.miValoracion != null) {
                return Column(
                  children: [
                    const Icon(Icons.stars, color: Colors.green, size: 40),
                    const SizedBox(height: 8),
                    Text(
                      '¡Gracias por valorar a $nombreVendedor!',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Le diste ${state.miValoracion} estrella${state.miValoracion! > 1 ? 's' : ''}',
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                );
              }

              if (state is RatingLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                children: [
                  Text(
                    '¿Cómo calificarías a $nombreVendedor?',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: const Icon(
                          Icons.star_border,
                          color: Colors.amber,
                          size: 36,
                        ),
                        onPressed: () async {
                          final confirm = await context.read<RatingCubit>().enviarValoracion(index + 1);
                          if (confirm && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('¡Valoración de ${index + 1} estrella(s) guardada!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            // Al guardar, el Cubit emitirá un nuevo estado con miValoracion != null
                            // y el BlocBuilder reconstruirá la UI mostrando el mensaje de agradecimiento.
                          }
                        },
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
