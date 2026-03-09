import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unimet_marketplace/domain/entities/cart_item.dart';

class CartState {
  final List<CartItem> items;
  
  CartState({required this.items});

  double get totalAmount => items.fold(0, (sum, item) => sum + item.price);
  int get itemCount => items.length;
}

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartState(items: []));

  void addItem(CartItem item) {
    final currentItems = List<CartItem>.from(state.items);
    if (!currentItems.any((i) => i.bookId == item.bookId)) {
      currentItems.add(item);
      emit(CartState(items: currentItems));
    }
  }

  void removeItem(String bookId) {
    final currentItems = List<CartItem>.from(state.items);
    currentItems.removeWhere((item) => item.bookId == bookId);
    emit(CartState(items: currentItems));
  }

  void clearCart() {
    emit(CartState(items: []));
  }
}
