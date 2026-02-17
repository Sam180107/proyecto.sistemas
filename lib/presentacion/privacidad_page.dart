import 'package:flutter/material.dart';

class PrivacidadPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Privacidad')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '- Tus datos (nombre, carrera, foto de perfil) solo son visibles para otros usuarios logueados.',
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(height: 20),
            Text(
              '- El sistema de favoritos y el historial de transacciones se cifran bajo estándares AES-256 para asegurar que tu actividad académica sea privada y segura.',
              style: TextStyle(fontSize: 30),
            ),
          ],
        ),
      ),
    );
  }
}
