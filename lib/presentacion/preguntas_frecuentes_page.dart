import 'package:flutter/material.dart';

class PreguntasFrecuentesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Preguntas Frecuentes')),
      body: Center(
        child: Text(
          'Preguntas frecuentes sobre la plataforma.',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
