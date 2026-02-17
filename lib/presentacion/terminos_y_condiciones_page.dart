import 'package:flutter/material.dart';

class TerminosYCondicionesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Términos y Condiciones')),
      body: Center(
        child: Text(
          'Información sobre los términos y condiciones.',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
