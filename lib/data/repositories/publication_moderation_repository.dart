import 'package:cloud_firestore/cloud_firestore.dart';

class PublicationModerationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> freezePublication(String docId, bool freeze) async {
    await _firestore.collection('libros').doc(docId).update({
      'estado': freeze ? 'Congelado' : 'Disponible',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> reportPublication({
    required String docId,
    required String userId,
    required String titulo,
    required String mensaje,
  }) async {
    print(
      "PublicationModerationRepository: Creating report in 'notificaciones' collection for user: $userId",
    );
    await _firestore.collection('notificaciones').add({
      'bookId': docId,
      'targetUserId': userId,
      'mensaje': mensaje,
      'fecha': FieldValue.serverTimestamp(),
      'leido': false,
      'titulo': titulo,
    });
  }

  Future<void> deletePublication(String docId) async {
    await _firestore.collection('libros').doc(docId).delete();
  }
}
