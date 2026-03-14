import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

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
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

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

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona una imagen para el libro'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Debes iniciar sesión para publicar');
      }

      // Obtener datos del perfil del usuario
      final userDoc = await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();
      if (!userDoc.exists) {
        throw Exception('Perfil de usuario no encontrado. Completa tu perfil primero.');
      }
      final userData = userDoc.data()!;

      final double? precio = double.tryParse(
        _precioController.text.replaceAll(',', ''),
      );

      // --- SUBIDA A SUPABASE STORAGE ---
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final supabase = Supabase.instance.client;

      if (kIsWeb) {
        final bytes = await _selectedImage!.readAsBytes();
        await supabase.storage
            .from('libros_imagenes')
            .uploadBinary(
              fileName,
              bytes,
              fileOptions: const FileOptions(contentType: 'image/jpeg'),
            );
      } else {
        await supabase.storage
            .from('libros_imagenes')
            .upload(
              fileName,
              File(_selectedImage!.path),
              fileOptions: const FileOptions(contentType: 'image/jpeg'),
            );
      }

      final String imageUrl = supabase.storage
          .from('libros_imagenes')
          .getPublicUrl(fileName);
      // --- FIN SUBIDA ---

      // Generar iniciales del nombre
      String nombre = userData['nombre'] ?? 'Usuario';
      String iniciales = nombre.isNotEmpty ? nombre.split(' ').map((e) => e[0]).take(2).join('').toUpperCase() : 'UN';

      await FirebaseFirestore.instance.collection('libros').add({
        'titulo': _tituloController.text.trim(),
        'autor': _autorController.text.trim(),
        'materia': _materiaController.text.trim(),
        'precio': precio ?? 0.0,
        'tipo': _tipoTransaccion,
        'tipoTransaccion': _tipoTransaccion,
        'categoria': _categoria,
        'imageUrl': imageUrl, // Guardamos la URL de la imagen
        'userEmail': user.email,
        'userId': user.uid,
        'vendedor': nombre,
        'carrera': userData['carrera'] ?? 'Estudiante',
        'rol': userData['rol'] ?? 'Estudiante', // Nuevo campo
        'iniciales': iniciales,
        'fechaCreacion': FieldValue.serverTimestamp(),
        'estado': 'Pendiente',
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
                    // IMAGEN SELECTOR
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          print("Intentando abrir galería...");
                          try {
                            final XFile? image = await _picker.pickImage(
                              source: ImageSource.gallery,
                              imageQuality:
                                  50, // Reducimos calidad para asegurar compatibilidad
                              maxWidth: 1000,
                              maxHeight: 1000,
                            );
                            if (image != null) {
                              print("Imagen seleccionada: ${image.path}");
                              setState(() => _selectedImage = image);
                            } else {
                              print("No se seleccionó ninguna imagen.");
                            }
                          } catch (e) {
                            print("Error al abrir galería: $e");
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Error al abrir la galería: $e',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        behavior: HitTestBehavior
                            .opaque, // Asegura que el área sea clickeable
                        child: Container(
                          width: double
                              .infinity, // Hacemos el área un poco más grande
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey[400]!),
                            image: _selectedImage != null
                                ? DecorationImage(
                                    image: kIsWeb
                                        ? NetworkImage(_selectedImage!.path)
                                        : FileImage(File(_selectedImage!.path))
                                              as ImageProvider,
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _selectedImage == null
                              ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Añadir Foto',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                )
                              : null,
                        ),
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
                        child: Text(
                          widget.bookId != null ? 'Guardar Cambios' : 'Publicar Ahora',
                          style: const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
