import 'package:dartz/dartz.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/payment.dart';
import '../../domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final Razorpay _razorpay;
  final FirebaseFirestore _firestore;

  PaymentRepositoryImpl(this._razorpay, this._firestore);

  @override
  Future<Either<Failure, Payment>> processPayment({
    required double amount,
    required MeetupPackage package,
    required String orderId,
  }) async {
    try {
      // Configure Razorpay options
      final options = {
        'key': 'YOUR_RAZORPAY_KEY', // TODO: Add your Razorpay key
        'amount': (amount * 100).toInt(), // Amount in paise
        'name': 'Senorita Dating',
        'description': '${package.name} - Premium Dating Experience',
        'order_id': orderId,
        'prefill': {
          'contact': '9999999999', // TODO: Get user phone
          'email': 'user@example.com' // TODO: Get user email
        },
        'theme': {
          'color': '#FF6B9D'
        }
      };

      // Open Razorpay checkout
      _razorpay.open(options);

      // Create payment record in database
      final paymentDoc = await _firestore.collection('payments').add({
        'orderId': orderId,
        'amount': amount,
        'currency': 'INR',
        'status': 'processing',
        'method': 'razorpay',
        'package': {
          'id': package.id,
          'name': package.name,
          'price': package.price,
          'type': package.type.toString(),
        },
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Return payment object (status will be updated via webhook)
      return Right(Payment(
        id: paymentDoc.id,
        orderId: orderId,
        amount: amount,
        status: PaymentStatus.processing,
        method: PaymentMethod.razorpay,
        createdAt: DateTime.now(),
        package: package,
      ));
    } catch (e) {
      return Left(PaymentFailure('Payment processing failed: $e'));
    }
  }

  @override
  Future<Either<Failure, Payment>> verifyPayment({
    required String paymentId,
    required String orderId,
    required String signature,
  }) async {
    try {
      // TODO: Implement payment verification with Razorpay
      // Verify the payment signature
      
      // Update payment status in database
      await _firestore.collection('payments').doc(paymentId).update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
        'razorpayPaymentId': paymentId,
        'razorpaySignature': signature,
      });

      // Get updated payment record
      final paymentDoc = await _firestore.collection('payments').doc(paymentId).get();
      final data = paymentDoc.data()!;

      return Right(Payment(
        id: paymentDoc.id,
        orderId: data['orderId'],
        amount: data['amount'].toDouble(),
        status: PaymentStatus.completed,
        method: PaymentMethod.razorpay,
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        completedAt: (data['completedAt'] as Timestamp).toDate(),
        package: MeetupPackage(
          id: data['package']['id'],
          name: data['package']['name'],
          price: data['package']['price'].toDouble(),
          description: '',
          includes: [],
          type: PackageType.values.firstWhere(
            (e) => e.toString() == data['package']['type'],
          ),
        ),
      ));
    } catch (e) {
      return Left(PaymentFailure('Payment verification failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> refundPayment(String paymentId) async {
    try {
      // TODO: Implement refund logic with Razorpay
      
      // Update payment status
      await _firestore.collection('payments').doc(paymentId).update({
        'status': 'refunded',
        'refundedAt': FieldValue.serverTimestamp(),
      });

      return const Right(null);
    } catch (e) {
      return Left(PaymentFailure('Refund failed: $e'));
    }
  }
}

abstract class PaymentRepository {
  Future<Either<Failure, Payment>> processPayment({
    required double amount,
    required MeetupPackage package,
    required String orderId,
  });

  Future<Either<Failure, Payment>> verifyPayment({
    required String paymentId,
    required String orderId,
    required String signature,
  });

  Future<Either<Failure, void>> refundPayment(String paymentId);
}

class PaymentFailure extends Failure {
  PaymentFailure(String message) : super(message);
}