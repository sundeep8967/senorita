import 'package:equatable/equatable.dart';

class Payment extends Equatable {
  final String id;
  final String orderId;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final PaymentMethod method;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? failureReason;
  final MeetupPackage package;

  const Payment({
    required this.id,
    required this.orderId,
    required this.amount,
    this.currency = 'INR',
    required this.status,
    required this.method,
    required this.createdAt,
    this.completedAt,
    this.failureReason,
    required this.package,
  });

  @override
  List<Object?> get props => [
        id,
        orderId,
        amount,
        currency,
        status,
        method,
        createdAt,
        completedAt,
        failureReason,
        package,
      ];
}

enum PaymentStatus { pending, processing, completed, failed, cancelled }

enum PaymentMethod { razorpay, upi, card, netbanking, wallet }

class MeetupPackage extends Equatable {
  final String id;
  final String name;
  final double price;
  final String description;
  final List<String> includes;
  final PackageType type;

  const MeetupPackage({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.includes,
    required this.type,
  });

  @override
  List<Object> get props => [id, name, price, description, includes, type];
}

enum PackageType { basic, premium, luxury }