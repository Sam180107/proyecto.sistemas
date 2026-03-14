import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CoraCubit extends Cubit<bool> { // Simplificado a bool para tu lógica actual
  CoraCubit() : super(false);

  Future<void> toggleFavorito(String idLibro, bool actualmenteEsFavorito) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null || idLibro.isEmpty) return; // Evita errores si el ID llega vacío

    final docRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(userId)
        .collection('favoritos')
        .doc(idLibro);

    try {
      if (actualmenteEsFavorito) {
        await docRef.delete();
      } else {
        await docRef.set({
          'idLibro': idLibro,
          'fecha_agregado': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print("Error en Firebase: $e");
    }
  }
}