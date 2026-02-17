import 'package:flutter/material.dart';

class TerminosYCondicionesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Términos y Condiciones')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '- Al utilizar este portal, aceptas que el SDI actúa únicamente como intermediario.',
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(height: 20),
            Text(
              '- No nos hacemos responsables por el estado físico de los libros ni por los acuerdos económicos privados entre estudiantes.',
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(height: 20),
            Text(
              '- La propiedad del software y del Logo SDI pertenece exclusivamente a la institución.',
              style: TextStyle(fontSize: 30),
            ),
          ],
        ),
      ),
    );
  }
}
