import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class RatingState {}
class RatingInitial extends RatingState {}
class RatingLoading extends RatingState {}
class RatingLoaded extends RatingState {
  final double promedio;
  final int totalValoraciones;
  final int? miValoracion; // null si no ha valorado
  RatingLoaded({required this.promedio, required this.totalValoraciones, this.miValoracion});
}
class RatingError extends RatingState {
  final String mensaje;
  RatingError(this.mensaje);
}

class RatingCubit extends Cubit<RatingState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _ratingSubscription;
  String? _currentUserId;

  RatingCubit() : super(RatingInitial());

  void cargarValoraciones(String usuarioValoradoId) {
    _currentUserId = usuarioValoradoId;
    emit(RatingLoading());

    _ratingSubscription?.cancel();
    _ratingSubscription = _firestore
        .collection('valoraciones')
        .where('usuarioValoradoId', isEqualTo: usuarioValoradoId)
        .snapshots()
        .listen(
          (snapshot) async {
            try {
              final valoraciones = snapshot.docs;
              double promedio = 0.0;
              int totalValoraciones = valoraciones.length;
              int? miValoracion;

              if (totalValoraciones > 0) {
                double suma = valoraciones.fold(0.0, (sum, doc) => sum + (doc['estrellas'] ?? 0.0));
                promedio = suma / totalValoraciones;
              }

              // Verificar si el usuario actual ya valoró
              if (_auth.currentUser != null) {
                final miRatingDocs = valoraciones.where(
                  (doc) => doc['usuarioValoradorId'] == _auth.currentUser!.uid,
                );
                if (miRatingDocs.isNotEmpty) {
                  miValoracion = miRatingDocs.first['estrellas'];
                }
              }

              emit(RatingLoaded(
                promedio: promedio,
                totalValoraciones: totalValoraciones,
                miValoracion: miValoracion,
              ));
            } catch (e) {
              emit(RatingError("Error al cargar valoraciones: $e"));
            }
          },
          onError: (error) => emit(RatingError("Error de red: $error")),
        );
  }

  Future<bool> enviarValoracion(int estrellas) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null || _currentUserId == null) return false;

      // Verificar si ya valoró
      final existingRating = await _firestore
          .collection('valoraciones')
          .where('usuarioValoradoId', isEqualTo: _currentUserId)
          .where('usuarioValoradorId', isEqualTo: currentUser.uid)
          .get();

      if (existingRating.docs.isNotEmpty) {
        // Actualizar valoración existente
        await existingRating.docs.first.reference.update({
          'estrellas': estrellas,
          'fecha': FieldValue.serverTimestamp(),
        });
      } else {
        // Crear nueva valoración
        await _firestore.collection('valoraciones').add({
          'usuarioValoradoId': _currentUserId!,
          'usuarioValoradorId': currentUser.uid,
          'estrellas': estrellas,
          'fecha': FieldValue.serverTimestamp(),
        });
      }

      return true;
    } catch (e) {
      emit(RatingError("Error al guardar valoración: $e"));
      return false;
    }
  }

  @override
  Future<void> close() {
    _ratingSubscription?.cancel();
    return super.close();
  }
}