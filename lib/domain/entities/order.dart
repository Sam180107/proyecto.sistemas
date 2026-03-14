import 'package:cloud_firestore/cloud_firestore.dart';

class BookOrder {
  final String id;
  final String buyerId;
  final String sellerId;
  final String bookId;
  final String bookTitle;
  final String bookAuthor;
  final double price;
  final String tipoTransaccion; // 'Venta' or 'Intercambio'
  final String status; // 'pending', 'accepted', 'paid', 'rejected', 'completed'
  final String tipoTransaccion;
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
    required this.tipoTransaccion,
    required this.status,
    this.tipoTransaccion = 'Venta',
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
      tipoTransaccion: data['tipoTransaccion'] ?? 'Venta', // Default to 'Venta' if not specified
      status: data['status'] ?? 'pending',
      tipoTransaccion: data['tipoTransaccion'] ?? 'Venta',
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
      'tipoTransaccion': tipoTransaccion,
      'status': status,
      'tipoTransaccion': tipoTransaccion,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'buyerName': buyerName,
      'sellerName': sellerName,
    };
  }
}