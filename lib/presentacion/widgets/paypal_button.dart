import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'paypal_button_stub.dart'
    if (dart.library.html) 'paypal_button_web_implementation.dart';

class PaypalButton extends StatelessWidget {
  final String amount;
  final Function(dynamic) onPaymentSuccess;

  const PaypalButton({
    super.key,
    required this.amount,
    required this.onPaymentSuccess,
  });

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return const Center(
        child: Text(
          'El pago con PayPal solo esta disponible en la web actualmente.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return PaypalButtonWebImplementation(
      amount: amount,
      onPaymentSuccess: onPaymentSuccess,
    );
  }
}
