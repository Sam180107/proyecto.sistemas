import 'package:flutter/material.dart';

class ComoFuncionaPage extends StatelessWidget {
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
                      'Cómo Funciona',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade800,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Identificación Segura: Accede con tus credenciales institucionales. El sistema reconoce automáticamente tu carrera y semestre.',
                      style: TextStyle(fontSize: 20, color: Colors.black87),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Gestión de Inventario: Sube tus materiales (libros, guías, apuntes) escaneando el código de barras o completando el formulario rápido de Material Design 3.',
                      style: TextStyle(fontSize: 20, color: Colors.black87),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Match Inteligente: Nuestro algoritmo conecta tu oferta con estudiantes que buscan exactamente ese material, priorizando la cercanía y la reputación del vendedor.',
                      style: TextStyle(fontSize: 20, color: Colors.black87),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Intercambio Seguro: Coordina el punto de entrega dentro del campus y califica la experiencia para mantener la integridad de la comunidad SDI.',
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
