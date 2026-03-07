import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PublicarLibroPage extends StatefulWidget {
  const PublicarLibroPage({super.key});

  @override
  State<PublicarLibroPage> createState() => _PublicarLibroPageState();
}

class _PublicarLibroPageState extends State<PublicarLibroPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _autorController = TextEditingController();
  final _materiaController = TextEditingController();
  final _precioController = TextEditingController();

  String _tipoTransaccion = 'Venta';
  String _categoria = 'LITERATURA';
  bool _isLoading = false;

  @override
  void dispose() {
    _tituloController.dispose();
    _autorController.dispose();
    _materiaController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  Future<void> _publicarLibro() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Debes iniciar sesión para publicar');
      }

      final double? precio = double.tryParse(
        _precioController.text.replaceAll(',', ''),
      );

      await FirebaseFirestore.instance.collection('libros').add({
        'titulo': _tituloController.text.trim(),
        'autor': _autorController.text.trim(),
        'materia': _materiaController.text.trim(),
        'precio': precio ?? 0.0,
        'tipo': _tipoTransaccion,
        'tipoTransaccion':
            _tipoTransaccion, // Added both for compatibility with existing HomePage logic
        'categoria': _categoria,
        'userEmail': user.email,
        'userId': user.uid,
        'fechaCreacion': FieldValue.serverTimestamp(),
        'estado': 'Pendiente', // Could be for admin validation
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Libro publicado con éxito!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al publicar: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicar Material'),
        backgroundColor: const Color(0xFF003870),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Detalles del Libro',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF003870),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _tituloController,
                      decoration: const InputDecoration(
                        labelText: 'Título del libro',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.book),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Campo requerido'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _autorController,
                      decoration: const InputDecoration(
                        labelText: 'Autor',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Campo requerido'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _materiaController,
                      decoration: const InputDecoration(
                        labelText: 'Materia / Carrera',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.school),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Campo requerido'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _precioController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Precio',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.attach_money),
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Campo requerido'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _tipoTransaccion,
                            decoration: const InputDecoration(
                              labelText: 'Tipo',
                              border: OutlineInputBorder(),
                            ),
                            items: ['Venta', 'Intercambio', 'Donación']
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _tipoTransaccion = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _categoria,
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          [
                                'LITERATURA',
                                'INGENIERÍA',
                                'DERECHO',
                                'ECONOMÍA',
                                'OTROS',
                              ]
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                      onChanged: (val) => setState(() => _categoria = val!),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _publicarLibro,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003870),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Publicar Ahora',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
