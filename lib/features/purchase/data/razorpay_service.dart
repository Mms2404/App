// RAZORPAY SERVICE
// -----------------------------------------------------------------------------
// Thin wrapper around the razorpay_flutter SDK. Exposes `openPayment` as a
// Future that completes with a Razorpay success payload, or throws with an
// error. Callers don't see the SDK's event-listener pattern.
// -----------------------------------------------------------------------------

import 'dart:async';
import 'package:app/api/keys.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

// Razorpay public key — fine to ship in the app (it's the test key).
// Move to --dart-define for production.
const String _razorpayKeyId = RAZORPAY_KEY_ID; 

class RazorpaySuccess {
  final String orderId;
  final String paymentId;
  final String signature;

  RazorpaySuccess({
    required this.orderId,
    required this.paymentId,
    required this.signature,
  });
}

class RazorpayException implements Exception {
  final String message;
  RazorpayException(this.message);
  @override
  String toString() => message;
}

class RazorpayService {
  late final Razorpay _razorpay;
  Completer<RazorpaySuccess>? _completer;

  RazorpayService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }

  void dispose() {
    _razorpay.clear();
  }

  /// Opens the Razorpay payment screen. Returns the success payload, or
  /// throws RazorpayException on cancel/failure.
  Future<RazorpaySuccess> openPayment({
    required String razorpayOrderId,
    required double amount,
    required String phone,
    required String name,
  }) {
    _completer = Completer<RazorpaySuccess>();

    final options = {
      'key': _razorpayKeyId,
      'amount': (amount * 100).round(),  // Razorpay wants paise
      'name': 'Plant Shop',
      'description': 'Order payment',
      'order_id': razorpayOrderId,
      'prefill': {
        'contact': phone,
      },
      'theme': {
        'color': '#4ADE80',  // matches your AppColors.success
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      _completer!.completeError(RazorpayException(e.toString()));
    }

    return _completer!.future;
  }

  void _onSuccess(PaymentSuccessResponse response) {
    _completer?.complete(RazorpaySuccess(
      orderId: response.orderId ?? '',
      paymentId: response.paymentId ?? '',
      signature: response.signature ?? '',
    ));
    _completer = null;
  }

  void _onError(PaymentFailureResponse response) {
    final code = response.code ?? -1;
    final msg = response.message ?? 'Payment failed';
    // Razorpay error code 0 = user cancelled
    if (code == 0 || msg.toLowerCase().contains('cancel')) {
      _completer?.completeError(RazorpayException('Payment cancelled'));
    } else {
      _completer?.completeError(RazorpayException(msg));
    }
    _completer = null;
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    // Not used — but the SDK requires the listener to be registered.
  }
}