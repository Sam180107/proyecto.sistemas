// ignore_for_file: avoid_web_libraries_in_flutter, undefined_function, undefined_method, uri_does_not_exist
import 'dart:html' as html;
import 'dart:js_util'; 
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

class PaypalButtonsOptions {
  final dynamic Function(dynamic, dynamic)? createOrder;
  final dynamic Function(dynamic, dynamic)? onApprove;

  PaypalButtonsOptions({this.createOrder, this.onApprove});
  
  dynamic toJs() {
    return jsify({
      if (createOrder != null) 'createOrder': allowInterop(createOrder!),
      if (onApprove != null) 'onApprove': allowInterop(onApprove!),
    });
  }
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
  final String _viewId = 'paypal-button-container';

  @override
  void initState() {
    super.initState();
    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(_viewId, (int viewId) {
      final div = html.DivElement()
        ..id = _viewId
        ..style.width = '100%'
        ..style.height = '100%';
      return div;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initPaypalButton();
    });
  }

  void _initPaypalButton() {
    final paypal = getProperty(html.window, 'paypal');
    if (paypal != null) {
      final options = jsify({
        'createOrder': allowInterop((data, actions) {
          return callMethod(getProperty(actions, 'order'), 'create', [
            jsify({
              'purchase_units': [
                {
                  'amount': {
                    'value': widget.amount,
                  }
                }
              ]
            })
          ]);
        }),
        'onApprove': allowInterop((data, actions) async {
          final result = await promiseToFuture(callMethod(getProperty(actions, 'order'), 'capture', []));
          widget.onPaymentSuccess(result);
        }),
      });

      final buttons = callMethod(paypal, 'Buttons', [options]);
      callMethod(buttons, 'render', ['#$_viewId']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewId);
  }
}
