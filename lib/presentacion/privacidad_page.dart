import 'package:flutter/material.dart';

class PrivacidadPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Privacidad')),
      body: Center(
        child: Text(
          'Información sobre privacidad.',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
