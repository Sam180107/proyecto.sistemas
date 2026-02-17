import 'package:flutter/material.dart';

class ComoFuncionaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cómo Funciona')),
      body: Center(
        child: Text(
          'Información sobre cómo funciona la plataforma.',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
