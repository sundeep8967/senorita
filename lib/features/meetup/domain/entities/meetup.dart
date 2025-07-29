import 'package:equatable/equatable.dart';
import '../../payment/domain/entities/payment.dart';
import '../../transportation/domain/entities/cab_booking.dart';

class Meetup extends Equatable {
  final String id;
  final String matchId;
  final String boyUserId;
  final String girlUserId;
  final String hotelId;
  final String hotelName;
  final String hotelAddress;
  final DateTime scheduledDateTime;
  final MeetupPackage package;
  final MeetupStatus status;
  final Payment payment;
  final CabBooking? girlCabBooking;
  final CabBooking? boyCabBooking; // Optional return cab for boy
  final String? specialInstructions;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final MeetupFeedback? feedback;

  const Meetup({
    required this.id,
    required this.matchId,
    required this.boyUserId,
    required this.girlUserId,
    required this.hotelId,
    required this.hotelName,
    required this.hotelAddress,
    required this.scheduledDateTime,
    required this.package,
    required this.status,
    required this.payment,
    this.girlCabBooking,
    this.boyCabBooking,
    this.specialInstructions,
    required this.createdAt,
    this.confirmedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.feedback,
  });

  @override
  List<Object?> get props => [
        id,
        matchId,
        boyUserId,
        girlUserId,
        hotelId,
        hotelName,
        hotelAddress,
        scheduledDateTime,
        package,
        status,
        payment,
        girlCabBooking,
        boyCabBooking,
        specialInstructions,
        createdAt,
        confirmedAt,
        completedAt,
        cancelledAt,
        cancellationReason,
        feedback,
      ];
}

enum MeetupStatus {
  paymentPending,
  paymentCompleted,
  girlConfirmationPending,
  confirmed,
  cabBooked,
  inProgress,
  completed,
  cancelled,
  noShow
}

class MeetupFeedback extends Equatable {
  final String id;
  final String meetupId;
  final String userId;
  final int rating; // 1-5 stars
  final String? comment;
  final List<String> tags; // ['great_conversation', 'punctual', 'respectful']
  final bool wouldMeetAgain;
  final DateTime createdAt;

  const MeetupFeedback({
    required this.id,
    required this.meetupId,
    required this.userId,
    required this.rating,
    this.comment,
    this.tags = const [],
    required this.wouldMeetAgain,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        meetupId,
        userId,
        rating,
        comment,
        tags,
        wouldMeetAgain,
        createdAt,
      ];
}

class Hotel extends Equatable {
  final String id;
  final String name;
  final String address;
  final String city;
  final double latitude;
  final double longitude;
  final double rating;
  final List<String> amenities;
  final List<String> photos;
  final String contactNumber;
  final bool isPartner;
  final bool isActive;
  final List<String> supportedPackages; // ['basic', 'premium', 'luxury']
  final Map<String, dynamic> packageDetails; // Package-specific details

  const Hotel({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.amenities,
    required this.photos,
    required this.contactNumber,
    required this.isPartner,
    required this.isActive,
    required this.supportedPackages,
    required this.packageDetails,
  });

  @override
  List<Object> get props => [
        id,
        name,
        address,
        city,
        latitude,
        longitude,
        rating,
        amenities,
        photos,
        contactNumber,
        isPartner,
        isActive,
        supportedPackages,
        packageDetails,
      ];
}