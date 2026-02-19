import 'package:flutter/material.dart';

class PoliticasDeUsoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Back'),
        backgroundColor: const Color.fromARGB(255, 2, 126, 243),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Políticas de Uso',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade800,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Integridad Académica: Queda prohibida la venta de exámenes resueltos o materiales que violen las normas de la institución.',
                      style: TextStyle(fontSize: 20, color: Colors.black87),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Respeto Mutuo: Los mensajes entre vendedor y comprador deben ser profesionales. El acoso o lenguaje ofensivo resultará en la eliminación del perfil.',
                      style: TextStyle(fontSize: 20, color: Colors.black87),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Uso del Dashboard: Las herramientas de análisis son para uso estadístico y mejora del servicio, no para la extracción de datos personales.',
                      style: TextStyle(fontSize: 20, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
