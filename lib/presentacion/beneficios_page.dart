import 'package:flutter/material.dart';

class BeneficiosPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Beneficios')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '- Economía Circular: Reduce el gasto anual en libros hasta en un 60% mediante el intercambio y la compra de segunda mano.',
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(height: 10),
            Text(
              '- Sostenibilidad Ambiental: Al reutilizar materiales académicos, disminuimos la huella de papel y fomentamos un campus verde.',
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(height: 10),
            Text(
              '- Red Académica: Más que una transacción, facilitamos el contacto entre estudiantes de distintos niveles para tutorías y consejos sobre materias.',
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(height: 10),
            Text(
              '- Interfaz Optimizada: Diseño responsive que se adapta a tu monitor de escritorio (1440px) o a tu tablet mientras estás en clase.',
              style: TextStyle(fontSize: 30),
            ),
          ],
        ),
      ),
    );
  }
}
