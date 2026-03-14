import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Stream of unread admin reports for the current user
  Stream<List<Map<String, dynamic>>> unreadReportsStream() {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) return Stream.value([]);
      return _firestore
          .collection('notificaciones')
          .where('targetUserId', isEqualTo: user.uid)
          .where('leido', isEqualTo: false)
          .snapshots()
          .map((snap) {
            print(
              "NotificationRepository: Found ${snap.docs.length} unread admin reports for ${user.uid}",
            );
            return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
          });
    });
  }

  /// Stream of pending orders where the current user is the seller
  Stream<List<Map<String, dynamic>>> newSellerOrdersStream() {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) return Stream.value([]);
      return _firestore
          .collection('orders')
          .where('sellerId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'pending')
          .snapshots()
          .map((snap) {
            print(
              "NotificationRepository: Received ${snap.docs.length} pending orders for ${user.uid}",
            );
            return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
          });
    });
  }

  Future<void> markReportAsRead(String reportId) async {
    await _firestore.collection('notificaciones').doc(reportId).update({
      'leido': true,
    });
  }
}
