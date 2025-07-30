import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/payment.dart';

abstract class PaymentRepository {
  Future<Either<Failure, Payment>> createPayment({
    required String userId,
    required String targetUserId,
    required PackageType packageType,
    required double amount,
  });

  Future<Either<Failure, Payment>> processPayment({
    required String paymentId,
    required String razorpayPaymentId,
    required String razorpayOrderId,
  });

  Future<Either<Failure, Payment>> getPayment(String paymentId);

  Future<Either<Failure, List<Payment>>> getUserPayments(String userId);

  Future<Either<Failure, Payment>> refundPayment(String paymentId);

  Future<Either<Failure, bool>> verifyPayment({
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
  });
}