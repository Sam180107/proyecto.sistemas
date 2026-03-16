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
  /// Se agregó 'tipoTransaccion' para diferenciar entre Venta e Intercambio
  Future<void> createOrder({
    required String sellerId,
    required String bookId,
    required String bookTitle,
    required String bookAuthor,
    required double price,
    required String tipoTransaccion, // Parámetro añadido
  }) async {
    try {
      emit(OrderLoading()); // Opcional: emitir carga antes de iniciar

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        emit(OrderError('Usuario no autenticado'));
        return;
      }

      // Obtener nombres de comprador y vendedor desde Firestore
      final buyerDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      final sellerDoc = await _firestore.collection('users').doc(sellerId).get();

      String buyerName = buyerDoc.exists 
          ? (buyerDoc.data()?['nombre'] ?? 'Desconocido') 
          : 'Desconocido';

      String sellerName = sellerDoc.exists 
          ? (sellerDoc.data()?['nombre'] ?? 'Desconocido') 
          : 'Desconocido';

      // Creación del objeto de la entidad con el nuevo campo
      final order = BookOrder(
        id: '', // Firestore generará el ID
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
        tipoTransaccion: tipoTransaccion, // Campo asignado
      );

      final orderId = await _orderRepository.createOrder(order);
      emit(OrderCreated(orderId));
    } catch (e) {
      emit(OrderError('Error al crear la orden: $e'));
    }
  }

  /// Cargar órdenes donde el usuario actual es el comprador
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

  /// Cargar órdenes donde el usuario actual es el vendedor
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

  /// Actualizar estado de orden (Ej: de 'pending' a 'completed')
  Future<void> updateOrderStatus(String orderId, String status) async {
    if (orderId.isEmpty) {
      emit(OrderError('ID de orden inválido'));
      return;
    }
    try {
      await _orderRepository.updateOrderStatus(orderId, status);
      // El stream de Firebase actualizará la UI automáticamente
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