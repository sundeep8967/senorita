import 'package:cloud_firestore/cloud_firestore.dart';

enum MeetupStatus {
  pending,
  accepted,
  declined,
  completed,
  cancelled,
}

class Meetup {
  final String id;
  final String requestingUserId;
  final String invitedUserId;
  final String hotelId;
  final String packageType; // e.g., "Coffee" or "Dinner"
  final double packageCost;
  final MeetupStatus status;
  final Timestamp createdAt;
  final Timestamp? acceptedAt;
  final String paymentId;

  Meetup({
    required this.id,
    required this.requestingUserId,
    required this.invitedUserId,
    required this.hotelId,
    required this.packageType,
    required this.packageCost,
    this.status = MeetupStatus.pending,
    required this.createdAt,
    this.acceptedAt,
    required this.paymentId,
  });

  factory Meetup.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Meetup(
      id: doc.id,
      requestingUserId: data['requestingUserId'] ?? '',
      invitedUserId: data['invitedUserId'] ?? '',
      hotelId: data['hotelId'] ?? '',
      packageType: data['packageType'] ?? '',
      packageCost: (data['packageCost'] ?? 0.0).toDouble(),
      status: MeetupStatus.values.firstWhere(
        (e) => e.toString() == 'MeetupStatus.${data['status']}',
        orElse: () => MeetupStatus.pending,
      ),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      acceptedAt: data['acceptedAt'],
      paymentId: data['paymentId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'requestingUserId': requestingUserId,
      'invitedUserId': invitedUserId,
      'hotelId': hotelId,
      'packageType': packageType,
      'packageCost': packageCost,
      'status': status.toString().split('.').last,
      'createdAt': createdAt,
      'acceptedAt': acceptedAt,
      'paymentId': paymentId,
    };
  }
}
