import 'package:cloud_firestore/cloud_firestore.dart';

enum PaymentStatus {
  pending,
  success,
  failed,
}

class Payment {
  final String id;
  final String userId;
  final String meetupId;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final String gateway; // e.g., "Razorpay"
  final String? gatewayTransactionId;
  final Timestamp createdAt;

  Payment({
    required this.id,
    required this.userId,
    required this.meetupId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.gateway,
    this.gatewayTransactionId,
    required this.createdAt,
  });

  factory Payment.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Payment(
      id: doc.id,
      userId: data['userId'] ?? '',
      meetupId: data['meetupId'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'INR',
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString() == 'PaymentStatus.${data['status']}',
        orElse: () => PaymentStatus.pending,
      ),
      gateway: data['gateway'] ?? '',
      gatewayTransactionId: data['gatewayTransactionId'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'meetupId': meetupId,
      'amount': amount,
      'currency': currency,
      'status': status.toString().split('.').last,
      'gateway': gateway,
      'gatewayTransactionId': gatewayTransactionId,
      'createdAt': createdAt,
    };
  }
}
