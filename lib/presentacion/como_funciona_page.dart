import 'package:flutter/material.dart';

class ComoFuncionaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cómo Funciona')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '- Identificación Segura: Accede con tus credenciales institucionales. El sistema reconoce automáticamente tu carrera y semestre.',
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(height: 10),
            Text(
              '- Gestión de Inventario: Sube tus materiales (libros, guías, apuntes) escaneando el código de barras o completando el formulario rápido de Material Design 3.',
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(height: 10),
            Text(
              '- Match Inteligente: Nuestro algoritmo conecta tu oferta con estudiantes que buscan exactamente ese material, priorizando la cercanía y la reputación del vendedor.',
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(height: 10),
            Text(
              '- Intercambio Seguro: Coordina el punto de entrega dentro del campus y califica la experiencia para mantener la integridad de la comunidad SDI.',
              style: TextStyle(fontSize: 30),
            ),
          ],
        ),
      ),
    );
  }
}
