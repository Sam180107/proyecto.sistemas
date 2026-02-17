import 'package:flutter/material.dart';

class PoliticasDeUsoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Políticas de Uso')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '- Integridad Académica: Queda prohibida la venta de exámenes resueltos o materiales que violen las normas de la institución.',
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(height: 20),
            Text(
              '- Respeto Mutuo: Los mensajes entre vendedor y comprador deben ser profesionales. El acoso o lenguaje ofensivo resultará en la eliminación del perfil.',
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(height: 20),
            Text(
              '- Uso del Dashboard: Las herramientas de análisis son para uso estadístico y mejora del servicio, no para la extracción de datos personales.',
              style: TextStyle(fontSize: 30),
            ),
          ],
        ),
      ),
    );
  }
}
