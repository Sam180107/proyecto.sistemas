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
        await _firestore.collection('books').doc(bookId).update({
          'disponible': false,
          'updatedAt': FieldValue.serverTimestamp(),
        });
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
