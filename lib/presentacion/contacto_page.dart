import 'package:flutter/material.dart';

class ContactoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Contacto')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '- Soporte Técnico: ¿Problemas con el login o la visualización del card de perfil? Escríbenos a tecnico@sdi-portal.edu.',
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(height: 20),
            Text(
              '- Oficinas de Bienestar: Encuéntranos en el edificio central, planta alta, módulo de atención al estudiante.',
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(height: 20),
            Text(
              '- Reportes: Para denunciar un mal uso de la plataforma, utiliza el formulario interno bajo el asunto "Reporte de Usuario".',
              style: TextStyle(fontSize: 30),
            ),
          ],
        ),
      ),
    );
  }
}
