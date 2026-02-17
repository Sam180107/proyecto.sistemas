import 'package:flutter/material.dart';

class CentroDeAyudaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Centro de Ayuda')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '- Primeros Pasos: Tutorial sobre cómo configurar tu perfil y cambiar tu nombre o contraseña desde el Sidebar de usuario.',
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(height: 20),
            Text(
              '- Guía de Publicación: Requisitos de imagen y descripción para que tus libros se vendan más rápido en la Grid de Inicio.',
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(height: 20),
            Text(
              '- Resolución de Conflictos: Qué hacer si un material no coincide con la descripción o si un usuario no se presenta al intercambio.',
              style: TextStyle(fontSize: 30),
            ),
          ],
        ),
      ),
    );
  }
}
