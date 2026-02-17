import 'package:flutter/material.dart';

class CookiesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cookies')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '- Utilizamos cookies esenciales para mantener tu sesión activa y recordar si tienes permisos de Administrador.',
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(height: 20),
            Text(
              '- Esto evita que tengas que reingresar la contraseña cada vez que cambias entre el Home y el Dashboard.',
              style: TextStyle(fontSize: 30),
            ),
          ],
        ),
      ),
    );
  }
}
