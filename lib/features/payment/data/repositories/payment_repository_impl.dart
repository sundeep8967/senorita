import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../domain/models/payment_model.dart';
import '../../domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final FirebaseFirestore _firestore;
  final Razorpay _razorpay;
  Completer<PaymentResult>? _paymentCompleter;

  PaymentRepositoryImpl({FirebaseFirestore? firestore, Razorpay? razorpay})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _razorpay = razorpay ?? Razorpay() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void dispose() {
    _razorpay.clear(); // Removes all listeners
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _paymentCompleter?.complete(PaymentResult(
      status: PaymentResultStatus.success,
      transactionId: response.paymentId,
      message: 'Payment Successful',
    ));
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _paymentCompleter?.complete(PaymentResult(
      status: PaymentResultStatus.failed,
      message: 'Payment Failed: ${response.code} - ${response.message}',
    ));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _paymentCompleter?.complete(PaymentResult(
      status: PaymentResultStatus.pending,
      message: 'External Wallet Selected: ${response.walletName}',
    ));
  }

  CollectionReference get _payments => _firestore.collection('payments');

  @override
  Future<void> logPayment(Payment payment) async {
    try {
      await _payments.doc(payment.id).set(payment.toFirestore());
    } catch (e) {
      print('Error logging payment: $e');
      rethrow;
    }
  }

  @override
  Future<Payment?> getPaymentDetails(String paymentId) async {
    try {
      final doc = await _payments.doc(paymentId).get();
      if (doc.exists) {
        return Payment.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting payment details: $e');
      rethrow;
    }
  }

  @override
  Future<PaymentResult> processPayment(PaymentRequest request) async {
    _paymentCompleter = Completer<PaymentResult>();
    final apiKey = dotenv.env['RAZORPAY_API_KEY'];

    if (apiKey == null || apiKey == 'YOUR_RAZORPAY_KEY_HERE') {
      print('RAZORPAY_API_KEY not found in .env file.');
      return PaymentResult(
          status: PaymentResultStatus.failed,
          message: 'Razorpay API Key is not configured.');
    }

    final options = {
      'key': apiKey,
      'amount': (request.amount * 100).toInt(), // Amount in paise
      'name': 'Senorita App',
      'description': 'Meetup Payment',
      'prefill': {
        'contact': request.userPhone,
        'email': request.userEmail,
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      return PaymentResult(
          status: PaymentResultStatus.failed, message: 'Error opening Razorpay: $e');
    }

    return _paymentCompleter!.future;
  }
}
