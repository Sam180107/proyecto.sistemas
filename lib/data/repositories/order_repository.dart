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

    if (status == 'accepted') {
      final orderDoc = await _firestore.collection('orders').doc(orderId).get();
      if (orderDoc.exists) {
        final orderData = orderDoc.data()!;
        final bookId = orderData['bookId'];
        if (bookId != null && bookId.isNotEmpty) {
          await markBookAsSold(bookId);
        }
      }
    }
  }

  Future<void> markBookAsSold(String bookId) async {
    try {
      await _firestore.collection('libros').doc(bookId).update({
        'estado': 'Vendido',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error al marcar libro como vendido: $e');
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
