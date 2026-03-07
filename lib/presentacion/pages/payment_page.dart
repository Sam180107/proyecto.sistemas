import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unimet_marketplace/domain/cubits/order_cubit.dart';
import 'package:unimet_marketplace/domain/entities/order.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final BookOrder order = ModalRoute.of(context)!.settings.arguments as BookOrder;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pago'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Libro: ${order.bookTitle}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Autor: ${order.bookAuthor}'),
            Text('Precio: \$${order.price.toStringAsFixed(2)}'),
            Text('Vendedor: ${order.sellerName ?? 'Desconocido'}'),
            const SizedBox(height: 20),
            const Text('Método de pago: Transferencia bancaria / Efectivo'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<OrderCubit>().updateOrderStatus(order.id, 'paid');
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pago confirmado')),
                );
              },
              child: const Text('Confirmar Pago'),
            ),
          ],
        ),
      ),
    );
  }
}