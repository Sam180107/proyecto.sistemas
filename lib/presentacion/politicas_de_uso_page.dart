import 'package:flutter/material.dart';

class PoliticasDeUsoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Políticas de Uso')),
      body: Center(
        child: Text(
          'Información sobre las políticas de uso.',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
