import 'package:flutter/material.dart';

class CentroDeAyudaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Centro de Ayuda')),
      body: Center(
        child: Text(
          'Bienvenido al centro de ayuda.',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
