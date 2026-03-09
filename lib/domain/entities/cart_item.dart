class CartItem {
  final String bookId;
  final String title;
  final String author;
  final double price;
  final String sellerId;
  final String? imageUrl;

  CartItem({
    required this.bookId,
    required this.title,
    required this.author,
    required this.price,
    required this.sellerId,
    this.imageUrl,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItem &&
          runtimeType == other.runtimeType &&
          bookId == other.bookId;

  @override
  int get hashCode => bookId.hashCode;
}
