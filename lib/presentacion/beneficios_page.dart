import 'package:flutter/material.dart';

class BeneficiosPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Beneficios')),
      body: Center(
        child: Text(
          'Información sobre los beneficios de la plataforma.',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
