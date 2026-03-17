// ignore_for_file: avoid_web_libraries_in_flutter, undefined_function, undefined_method, uri_does_not_exist
import 'dart:html' as html;
import 'dart:js_util'; 
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:js/js.dart';

@JS('paypal.Buttons')
class PaypalButtons {
  external factory PaypalButtons(PaypalButtonsOptions options);
  external dynamic render(dynamic selector);
}

@JS()
@anonymous
class PaypalButtonsOptions {
  external factory PaypalButtonsOptions({
    dynamic Function(dynamic, dynamic) createOrder,
    dynamic Function(dynamic, dynamic) onApprove,
  });
}

@JS()
@anonymous
class PaypalActions {
  external PaypalOrder get order;
}

@JS()
@anonymous
class PaypalOrder {
  external dynamic create(dynamic options);
  external dynamic capture();
}

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
  late final String viewID;
  bool _isRendered = false;

  @override
  void initState() {
    super.initState();
    viewID = 'paypal-button-$hashCode';

    ui_web.platformViewRegistry.registerViewFactory(
      viewID,
      (int viewId) => html.DivElement()
        ..id = viewID
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.display = 'block',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _renderPaypalButton();
    });
  }

  void _renderPaypalButton() {
    if (_isRendered) return;

    final element = html.document.getElementById(viewID);
    if (element == null) {
      Future.delayed(const Duration(milliseconds: 200), _renderPaypalButton);
      return;
    }

    // Check if PayPal SDK is loaded
    if (getProperty(html.window, 'paypal') == null) {
      debugPrint('PayPal SDK not loaded yet, retrying...');
      Future.delayed(const Duration(milliseconds: 500), _renderPaypalButton);
      return;
    }

    _isRendered = true;

    // Ensure amount has 2 decimal places
    String formattedAmount = widget.amount.replaceAll('\$', '').trim();
    if (!formattedAmount.contains('.')) {
      formattedAmount = '$formattedAmount.00';
    }

    try {
      final options = PaypalButtonsOptions(
        createOrder: allowInterop((data, actions) {
          final paypalActions = actions as PaypalActions;
          return paypalActions.order.create(jsify({
            'purchase_units': [
              {
                'amount': {'value': formattedAmount}
              }
            ]
          }));
        }),
        onApprove: allowInterop((data, actions) async {
          final paypalActions = actions as PaypalActions;
          try {
            final result = await promiseToFuture(paypalActions.order.capture());
            widget.onPaymentSuccess(result);
          } catch (e) {
            debugPrint('Error capturing PayPal payment: $e');
          }
        }),
      );

      PaypalButtons(options).render('#$viewID');
    } catch (e) {
      _isRendered = false;
      debugPrint('PayPal render error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 300,
        height: 150,
        child: HtmlElementView(viewType: viewID),
      ),
    );
  }
}
