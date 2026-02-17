import 'package:flutter/material.dart';

class PreguntasFrecuentesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Preguntas Frecuentes')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '- ¿Es exclusivo para la comunidad SDI? Sí, para garantizar la seguridad, el acceso está restringido a usuarios registrados con validación administrativa.',
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(height: 10),
            Text(
              '- ¿Cómo funciona el rol de Administrador? Los administradores (acceso mediante clave \"admin\") supervisan el Dashboard, analizan métricas de intercambio y moderan el contenido para evitar spam.',
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(height: 10),
            Text(
              '- ¿Qué hago si mi material no aparece en el buscador? Puedes usar el botón \"Publicar\" en el Header Superior para añadirlo manualmente con fotos y descripción detallada.',
              style: TextStyle(fontSize: 30),
            ),
          ],
        ),
      ),
    );
  }
}
