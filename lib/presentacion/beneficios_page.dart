import 'package:flutter/material.dart';

class BeneficiosPage extends StatelessWidget {
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
                      'Beneficios',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade800,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Economía Circular: Reduce el gasto anual en libros hasta en un 60% mediante el intercambio y la compra de segunda mano.',
                      style: TextStyle(fontSize: 20, color: Colors.black87),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Sostenibilidad Ambiental: Al reutilizar materiales académicos, disminuimos la huella de papel y fomentamos un campus verde.',
                      style: TextStyle(fontSize: 20, color: Colors.black87),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Red Académica: Más que una transacción, facilitamos el contacto entre estudiantes de distintos niveles para tutorías y consejos sobre materias.',
                      style: TextStyle(fontSize: 20, color: Colors.black87),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Interfaz Optimizada: Diseño responsive que se adapta a tu monitor de escritorio (1440px) o a tu tablet mientras estás en clase.',
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
