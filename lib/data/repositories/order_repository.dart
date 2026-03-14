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
            await markBookAsSold(bookId);
            // Mark the order so we don't decrement stock multiple times for the same order
            await _firestore.collection('orders').doc(orderId).update({
              'isStockDecremented': true,
            });
          }
        }
      }
    }
  }

  Future<void> markBookAsSold(String bookId) async {
    try {
      final docRef = _firestore.collection('libros').doc(bookId);
      final doc = await docRef.get();
      if (doc.exists) {
        final currentStock = doc.data()?['stock'] ?? 1;
        if (currentStock > 1) {
          await docRef.update({
            'stock': currentStock - 1,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          await docRef.update({
            'stock': 0,
            'estado': 'Vendido',
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      print('CRITICAL: Error al restar stock del libro $bookId: $e');
      if (e.toString().contains('permission-denied')) {
        print(
          'AVISO: Error de permisos de Firebase al intentar descontar stock. El comprador no puede editar el libro del vendedor.',
        );
      }
    }
  }

  Future<BookOrder?> getOrder(String orderId) async {
    final doc = await _firestore.collection('orders').doc(orderId).get();
    if (doc.exists) {
      return BookOrder.fromMap(doc.id, doc.data()!);
    }
    return null;
  }
}
