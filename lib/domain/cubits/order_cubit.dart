import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unimet_marketplace/data/repositories/order_repository.dart';
import 'package:unimet_marketplace/domain/entities/order.dart';

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

class OrderCubit extends Cubit<OrderState> {
  final OrderRepository _orderRepository;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _ordersSubscription;

  OrderCubit(this._orderRepository) : super(OrderInitial());

  // Crear una nueva orden
  Future<void> createOrder({
    required String sellerId,
    required String bookId,
    required String bookTitle,
    required String bookAuthor,
    required double price,
    required String tipoTransaccion,
    String status = 'pending',
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        emit(OrderError('Usuario no autenticado'));
        return;
      }

      // Obtener nombres de comprador y vendedor
      final buyerDoc = await _firestore.collection('usuarios').doc(currentUser.uid).get();
      final sellerDoc = await _firestore.collection('usuarios').doc(sellerId).get();

      String buyerName;
      if (buyerDoc.exists) {
        buyerName = buyerDoc.data()?['nombre'] ?? 'Desconocido';
      } else {
        buyerName = 'Desconocido';
      }

      String sellerName;
      if (sellerDoc.exists) {
        sellerName = sellerDoc.data()?['nombre'] ?? 'Desconocido';
      } else {
        sellerName = 'Desconocido';
      }

      final order = BookOrder(
        id: '', // Se asignará al crear
        buyerId: currentUser.uid,
        sellerId: sellerId,
        bookId: bookId,
        bookTitle: bookTitle,
        bookAuthor: bookAuthor,
        price: price,
        tipoTransaccion: tipoTransaccion,
        status: status,
        createdAt: DateTime.now(),
        buyerName: buyerName,
        sellerName: sellerName,
      );

      final orderId = await _orderRepository.createOrder(order);

      if (status == 'pending') {
        // Actualizar estado del material a 'Solicitado' si es el último en stock
        await _orderRepository.updateMaterialStatus(bookId, 'Solicitado');
      } else if (status == 'completed' || status == 'paid') {
        // Actualizar material a 'Entregado' tras la venta, evitando decrementos dobles
        await _orderRepository.updateMaterialStatus(bookId, 'Entregado');
        // Marcar la orden para que el repository no intente decrementar de nuevo
        await _firestore.collection('orders').doc(orderId).update({
          'isStockDecremented': true,
        });
      }

      String mensaje = status == 'pending' 
             ? 'Has recibido una nueva solicitud para "$bookTitle" de $buyerName.'
             : '¡Gran noticia! Has vendido "$bookTitle" a $buyerName por PayPal.';

      // Notificar al vendedor sobre la nueva solicitud o venta
      await _firestore.collection('notificaciones').add({
        'targetUserId': sellerId,
        'leido': false,
        'tipo': 'new_order',
        'mensaje': mensaje,
        'titulo': bookTitle,
        'fecha': FieldValue.serverTimestamp(),
      });

      emit(OrderCreated(orderId));
    } catch (e) {
      emit(OrderError('Error al crear la orden: $e'));
    }
  }

  // Cargar órdenes del comprador
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
      (orders) {
        if (!isClosed) emit(OrderLoaded(orders));
      },
      onError: (error) {
        if (!isClosed) emit(OrderError('Error al cargar órdenes: $error'));
      },
    );
  }

  // Cargar órdenes del vendedor
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
      (orders) {
        if (!isClosed) emit(OrderLoaded(orders));
      },
      onError: (error) {
        if (!isClosed) emit(OrderError('Error al cargar órdenes: $error'));
      },
    );
  }

  // Actualizar estado de orden (para vendedores)
  Future<void> updateOrderStatus(String orderId, String status) async {
    if (orderId.isEmpty) {
      emit(OrderError('ID de orden inválido'));
      return;
    }
    try {
      await _orderRepository.updateOrderStatus(orderId, status);
      
      // Manejar el flujo de estados del material
      if (status == 'rejected') {
        final orderDoc = await _firestore.collection('orders').doc(orderId).get();
        if (orderDoc.exists) {
          final bookId = orderDoc.data()?['bookId'];
          if (bookId != null) {
            await _orderRepository.updateMaterialStatus(bookId, 'Disponible');
          }
        }
      } else if (status == 'completed') {
        final orderDoc = await _firestore.collection('orders').doc(orderId).get();
        if (orderDoc.exists) {
          final bookId = orderDoc.data()?['bookId'];
          if (bookId != null) {
            await _orderRepository.updateMaterialStatus(bookId, 'Entregado');
          }
        }
      }

      // Enviar notificación al comprador si fue aceptada o rechazada
      if (status == 'accepted' || status == 'rejected') {
        final orderDoc = await _firestore.collection('orders').doc(orderId).get();
        if (orderDoc.exists) {
          final orderData = orderDoc.data()!;
          final buyerId = orderData['buyerId'];
          final bookTitle = orderData['bookTitle'];
          String statusText = status == 'accepted' ? 'aceptada' : 'rechazada';

          await _firestore.collection('notificaciones').add({
            'targetUserId': buyerId,
            'leido': false,
            'tipo': 'order_update',
            'mensaje': 'Tu solicitud para "$bookTitle" ha sido $statusText.',
            'titulo': bookTitle, // Reutilizando el campo \`titulo\` existente para consistencia
            'fecha': FieldValue.serverTimestamp(),
          });
        }
      }
      // El stream se actualizará automáticamente
    } catch (e) {
      emit(OrderError('Error al actualizar orden: $e'));
    }
  }

  // Marcar libro como vendido después de pago exitoso
  Future<void> markBookAsSold(String bookId) async {
    if (bookId.isEmpty) return;
    try {
      await _orderRepository.markBookAsSold(bookId);
    } catch (e) {
      print('Error en Cubit al marcar libro: $e');
    }
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    return super.close();
  }
}