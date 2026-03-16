import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unimet_marketplace/data/repositories/order_repository.dart';
import 'package:unimet_marketplace/domain/entities/order.dart';

// --- Estados del Cubit ---
abstract class OrderState {}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderLoaded extends OrderState {
  final List<BookOrder> orders;
  OrderLoaded(this.orders);
}

class OrderError extends OrderState {
  final String message;
  OrderError(this.message);
}

class OrderCreated extends OrderState {
  final String orderId;
  OrderCreated(this.orderId);
}

// --- Cubit Principal ---
class OrderCubit extends Cubit<OrderState> {
  final OrderRepository _orderRepository;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _ordersSubscription;

  OrderCubit(this._orderRepository) : super(OrderInitial());

  /// Crear una nueva orden
  Future<void> createOrder({
    required String sellerId,
    required String bookId,
    required String bookTitle,
    required String bookAuthor,
    required double price,
    required String tipoTransaccion,
  }) async {
    try {
      emit(OrderLoading());

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        emit(OrderError('Usuario no autenticado'));
        return;
      }

      final buyerDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      final sellerDoc = await _firestore.collection('users').doc(sellerId).get();

      String buyerName = buyerDoc.exists 
          ? (buyerDoc.data()?['nombre'] ?? 'Desconocido') 
          : 'Desconocido';

      String sellerName = sellerDoc.exists 
          ? (sellerDoc.data()?['nombre'] ?? 'Desconocido') 
          : 'Desconocido';

      final order = BookOrder(
        id: '', 
        buyerId: currentUser.uid,
        sellerId: sellerId,
        bookId: bookId,
        bookTitle: bookTitle,
        bookAuthor: bookAuthor,
        price: price,
        status: 'pending',
        createdAt: DateTime.now(),
        buyerName: buyerName,
        sellerName: sellerName,
        tipoTransaccion: tipoTransaccion,
      );

      final orderId = await _orderRepository.createOrder(order);
      emit(OrderCreated(orderId));
    } catch (e) {
      emit(OrderError('Error al crear la orden: $e'));
    }
  }

  /// MÉTODO NUEVO: Marcar como vendido / Reducir Stock
  Future<void> markBookAsSold(String bookId) async {
    try {
      // Usamos FieldValue.increment(-1) para que sea una operación atómica en Firebase
      await _firestore.collection('libros').doc(bookId).update({
        'stock': FieldValue.increment(-1),
      });
    } catch (e) {
      print("Error al actualizar stock: $e");
      emit(OrderError('Error al actualizar stock: $e'));
    }
  }

  void loadBuyerOrders() {
    emit(OrderLoading());
    _ordersSubscription?.cancel();
    
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      emit(OrderError('Usuario no autenticado'));
      return;
    }

    _ordersSubscription = _orderRepository.getBuyerOrders(currentUser.uid).map((orders) {
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    }).listen(
      (orders) => emit(OrderLoaded(orders)),
      onError: (error) => emit(OrderError('Error al cargar órdenes: $error')),
    );
  }

  void loadSellerOrders() {
    emit(OrderLoading());
    _ordersSubscription?.cancel();
    
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      emit(OrderError('Usuario no autenticado'));
      return;
    }

    _ordersSubscription = _orderRepository.getSellerOrders(currentUser.uid).map((orders) {
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    }).listen(
      (orders) => emit(OrderLoaded(orders)),
      onError: (error) => emit(OrderError('Error al cargar órdenes: $error')),
    );
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    if (orderId.isEmpty) {
      emit(OrderError('ID de orden inválido'));
      return;
    }
    try {
      await _orderRepository.updateOrderStatus(orderId, status);
    } catch (e) {
      emit(OrderError('Error al actualizar orden: $e'));
    }
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    return super.close();
  }
}