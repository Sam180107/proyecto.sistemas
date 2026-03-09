import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unimet_marketplace/domain/cubits/order_cubit.dart';
import 'package:unimet_marketplace/domain/entities/order.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 0) {
        context.read<OrderCubit>().loadBuyerOrders();
      } else {
        context.read<OrderCubit>().loadSellerOrders();
      }
    });
    // Cargar órdenes iniciales
    context.read<OrderCubit>().loadBuyerOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Intercambios'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Solicitados'),
            Tab(text: 'Solicitudes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersList(isBuyer: true),
          _buildOrdersList(isBuyer: false),
        ],
      ),
    );
  }

  Widget _buildOrdersList({required bool isBuyer}) {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, state) {
        if (state is OrderLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is OrderError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        if (state is OrderLoaded) {
          if (state.orders.isEmpty) {
            return Center(
              child: Text(
                isBuyer ? 'No tienes solicitudes realizadas' : 'No tienes solicitudes pendientes',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            itemCount: state.orders.length,
            itemBuilder: (context, index) {
              final BookOrder order = state.orders[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(order.bookTitle),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Autor: ${order.bookAuthor}'),
                      if (order.tipoTransaccion == 'Venta')
                        Text('Precio: \$${order.price.toStringAsFixed(2)}'),
                      Text('Tipo: ${order.tipoTransaccion}'),
                      Text(isBuyer ? 'Vendedor: ${order.sellerName ?? 'Desconocido'}' : 'Comprador: ${order.buyerName ?? 'Desconocido'}'),
                      Text('Estado: ${_getStatusText(order.status)}'),
                      Text('Fecha: ${_formatDate(order.createdAt)}'),
                    ],
                  ),
                  trailing: isBuyer
                      ? _buildBuyerActions(order)
                      : _buildSellerActions(order),
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBuyerActions(BookOrder order) {
    if (order.status == 'accepted') {
      return ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, '/payment', arguments: order),
        child: const Text('Pagar'),
      );
    }
    return Text(_getStatusText(order.status));
  }

  Widget _buildSellerActions(BookOrder order) {
    if (order.status == 'pending') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: () => _updateOrderStatus(order.id, 'accepted'),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () => _updateOrderStatus(order.id, 'rejected'),
          ),
        ],
      );
    } else if (order.status == 'paid') {
      return IconButton(
        icon: const Icon(Icons.check_circle, color: Colors.blue),
        onPressed: () => _updateOrderStatus(order.id, 'completed'),
      );
    }
    return Text(_getStatusText(order.status));
  }

  void _updateOrderStatus(String orderId, String status) {
    if (orderId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: ID de orden inválido')),
      );
      return;
    }
    context.read<OrderCubit>().updateOrderStatus(orderId, status);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Orden ${status == 'accepted' ? 'aceptada' : status == 'rejected' ? 'rechazada' : 'completada'}')),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pendiente';
      case 'accepted':
        return 'Aceptada';
      case 'paid':
        return 'Pagada';
      case 'rejected':
        return 'Rechazada';
      case 'completed':
        return 'Completada';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}