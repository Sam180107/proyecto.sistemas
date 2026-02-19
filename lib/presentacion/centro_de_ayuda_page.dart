import 'package:flutter/material.dart';

class CentroDeAyudaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Back'),
        backgroundColor: const Color.fromARGB(255, 2, 126, 243),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Centro de Ayuda',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade800,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Primeros Pasos: Tutorial sobre cómo configurar tu perfil y cambiar tu nombre o contraseña desde el Sidebar de usuario.',
                      style: TextStyle(fontSize: 20, color: Colors.black87),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Guía de Publicación: Requisitos de imagen y descripción para que tus libros se vendan más rápido en la Grid de Inicio.',
                      style: TextStyle(fontSize: 20, color: Colors.black87),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Resolución de Conflictos: Qué hacer si un material no coincide con la descripción o si un usuario no se presenta al intercambio.',
                      style: TextStyle(fontSize: 20, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
