import '../models/payment_model.dart';

class PaymentRequest {
  final double amount;
  final String currency;
  final String userName;
  final String userEmail;
  final String userPhone;

  PaymentRequest({
    required this.amount,
    required this.currency,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
  });
}

enum PaymentResultStatus {
  success,
  failed,
  pending,
}

class PaymentResult {
  final PaymentResultStatus status;
  final String? transactionId;
  final String? message;

  PaymentResult({
    required this.status,
    this.transactionId,
    this.message,
  });
}

abstract class PaymentRepository {
  /// Initiates and processes a payment through a payment gateway.
  Future<PaymentResult> processPayment(PaymentRequest request);

  /// Saves a record of the payment transaction to the database.
  Future<void> logPayment(Payment payment);

  /// Retrieves the details of a specific payment from the database.
  Future<Payment?> getPaymentDetails(String paymentId);
}
