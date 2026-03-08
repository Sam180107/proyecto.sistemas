import 'package:cloud_firestore/cloud_firestore.dart';

class BookOrder {
  final String id;
  final String buyerId;
  final String sellerId;
  final String bookId;
  final String bookTitle;
  final String bookAuthor;
  final double price;
  final String status; // 'pending', 'accepted', 'paid', 'rejected', 'completed'
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? buyerName;
  final String? sellerName;

  BookOrder({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    required this.bookId,
    required this.bookTitle,
    required this.bookAuthor,
    required this.price,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.buyerName,
    this.sellerName,
  });

  factory BookOrder.fromMap(String id, Map<String, dynamic> data) {
    return BookOrder(
      id: id,
      buyerId: data['buyerId'],
      sellerId: data['sellerId'],
      bookId: data['bookId'],
      bookTitle: data['bookTitle'],
      bookAuthor: data['bookAuthor'] ?? '',
      price: double.tryParse(data['price'].toString()) ?? 0.0,
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : null,
      buyerName: data['buyerName'],
      sellerName: data['sellerName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'buyerId': buyerId,
      'sellerId': sellerId,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'bookAuthor': bookAuthor,
      'price': price,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'buyerName': buyerName,
      'sellerName': sellerName,
    };
  }
}