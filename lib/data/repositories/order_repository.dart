import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unimet_marketplace/domain/entities/order.dart';

class OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createOrder(BookOrder order) async {
    final docRef = await _firestore.collection('orders').add(order.toMap());
    return docRef.id;
  }

  Stream<List<BookOrder>> getBuyerOrders(String buyerId) {
    return _firestore
        .collection('orders')
        .where('buyerId', isEqualTo: buyerId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BookOrder.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<BookOrder>> getSellerOrders(String sellerId) {
    return _firestore
        .collection('orders')
        .where('sellerId', isEqualTo: sellerId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BookOrder.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (status == 'accepted' || status == 'completed' || status == 'paid') {
      final orderDoc = await _firestore.collection('orders').doc(orderId).get();
      if (orderDoc.exists) {
        final orderData = orderDoc.data()!;
        final bookId = orderData['bookId'];
        if (bookId != null && bookId.isNotEmpty) {
          // Check if already decremented for this specific order somehow
          final isStockDecremented = orderData['isStockDecremented'] ?? false;
          if (!isStockDecremented) {
            await updateMaterialStatus(bookId, status == 'completed' ? 'Entregado' : null);
            // Mark the order so we don't decrement stock multiple times for the same order
            await _firestore.collection('orders').doc(orderId).update({
              'isStockDecremented': true,
            });
          }
        }
      }
    }
  }

  Future<void> updateMaterialStatus(String bookId, String? newStatus) async {
    try {
      final docRef = _firestore.collection('libros').doc(bookId);
      final doc = await docRef.get();
      if (doc.exists) {
        final data = doc.data()!;
        final currentStock = data['stock'] ?? 1;
        
        Map<String, dynamic> updates = {
          'updatedAt': FieldValue.serverTimestamp(),
        };

        if (newStatus != null) {
          updates['estado'] = newStatus;
          // Si el material ya ha sido entregado o vendido, nos aseguramos de que el stock sea coherente
          if (newStatus == 'Entregado' || newStatus == 'Vendido') {
            if (currentStock > 0) {
              updates['stock'] = currentStock - 1;
            } else {
              updates['stock'] = 0;
            }
          }
        } else {
          // Default behavior (decrement stock and mark as Entregado if last one)
          if (currentStock > 1) {
            updates['stock'] = currentStock - 1;
            // No cambiamos el estado si aún queda stock
          } else {
            updates['stock'] = 0;
            updates['estado'] = 'Entregado';
          }
        }
        
        await docRef.update(updates);
      }
    } catch (e) {
      print('AVISO: No se pudo actualizar el estado del material $bookId. Esto es normal si el usuario actual no es el dueño: $e');
      // No relanzamos el error para no romper el flujo de UI (ej. pago)
    }
  }

  Future<void> markBookAsSold(String bookId) async {
    await updateMaterialStatus(bookId, 'Entregado');
  }

  Future<BookOrder?> getOrder(String orderId) async {
    final doc = await _firestore.collection('orders').doc(orderId).get();
    if (doc.exists) {
      return BookOrder.fromMap(doc.id, doc.data()!);
    }
    return null;
  }
}
