import 'package:flutter/material.dart';

class DetalleLibroPage extends StatelessWidget {
  const DetalleLibroPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Extraemos los argumentos de forma segura
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Cabecera con Imagen y Precio
                _buildHeader(
                  context,
                  arguments['precio']!,
                  arguments['imagen']!,
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        arguments['titulo']!,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        arguments['autor']!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 25),

                      const Text(
                        "Estado de la Transacción",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildStatusTimeline(),

                      const SizedBox(height: 25),
                      _buildInfoCard("Descripción", arguments['descripcion']!),

                      const SizedBox(height: 25),
                      _buildSellerCard(
                        arguments['vendedor']!,
                        arguments['carrera']!,
                        arguments['iniciales']!,
                      ),

                      // Espacio final para que el scroll permita ver todo antes del botón
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. BOTÓN DE RETROCESO (Indispensable al usar Stack)
          Positioned(
            top: 45,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.9),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // 3. BOTÓN DE ACCIÓN FIJO EN LA PARTE INFERIOR
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: _buildBottomButton(),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS DE APOYO OPTIMIZADOS ---

  Widget _buildHeader(BuildContext context, dynamic precio, String rutaImagen) {
    return SizedBox(
      height: 320,
      width: double.infinity,
      child: Stack(
        children: [
          // Imagen con respaldo por si falla la ruta
          Positioned.fill(
            child: Container(
              color: Colors.grey[300],
              child: rutaImagen.startsWith('http')
                  ? Image.network(
                      rutaImagen,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey,
                          ),
                        );
                      },
                    )
                  : Image.asset(
                      rutaImagen,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
            ),
          ),
          // Gradiente para que el botón de volver se vea mejor
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Etiqueta de precio
          Positioned(
            bottom: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Text(
                "VENTA - \$ ${precio.toString()}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _statusItem("Disponible", Icons.check_circle, true),
          Expanded(
            child: Divider(indent: 10, endIndent: 10, color: Colors.grey[300]),
          ),
          _statusItem("Solicitado", Icons.radio_button_unchecked, false),
          Expanded(
            child: Divider(indent: 10, endIndent: 10, color: Colors.grey[300]),
          ),
          _statusItem("Aceptado", Icons.radio_button_unchecked, false),
        ],
      ),
    );
  }

  Widget _statusItem(String label, IconData icon, bool active) {
    return Column(
      children: [
        Icon(
          icon,
          color: active ? const Color(0xFF1E88E5) : Colors.grey,
          size: 24,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            color: active ? Colors.black : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String titulo, String contenido) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Text(
            contenido,
            style: const TextStyle(
              color: Colors.black87,
              height: 1.5,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerCard(String nombre, String carrera, String iniciales) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: const Color(0xFF003870),
            child: Text(
              iniciales,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  carrera,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // Aquí podrías navegar al perfil del vendedor
            },
            child: const Text(
              "Ver Perfil",
              style: TextStyle(
                color: Color(0xFF1E88E5),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E88E5).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          // Lógica para solicitar el libro
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E88E5),
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 0,
        ),
        child: const Text(
          "Solicitar Material",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
