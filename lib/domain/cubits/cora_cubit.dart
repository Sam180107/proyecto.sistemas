import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CoraCubit extends Cubit<List<String>> {
  CoraCubit() : super([]) {
    _escucharFavoritos();
  }

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  void _escucharFavoritos() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    // Escucha cambios en la subcolección de favoritos del usuario
    _db.collection('usuarios').doc(userId).collection('favoritos')
      .snapshots()
      .listen((snapshot) {
        final listaIds = snapshot.docs.map((doc) => doc.id).toList();
        emit(listaIds); 
      });
  }

  Future<void> toggleFavorito(String idLibro, bool actualmenteEsFavorito) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null || idLibro.isEmpty) return;

    final docRef = _db.collection('usuarios').doc(userId).collection('favoritos').doc(idLibro);

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
      debugPrint("Error en Firebase: $e");
    }
  }
}