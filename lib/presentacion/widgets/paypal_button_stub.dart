import 'package:flutter/material.dart';

class PaypalButtonWebImplementation extends StatefulWidget {
  final String amount;
  final Function(dynamic) onPaymentSuccess;

  const PaypalButtonWebImplementation({
    super.key,
    required this.amount,
    required this.onPaymentSuccess,
  });

  @override
  State<PaypalButtonWebImplementation> createState() => _PaypalButtonWebImplementationState();
}

class _PaypalButtonWebImplementationState extends State<PaypalButtonWebImplementation> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
