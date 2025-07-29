import 'package:equatable/equatable.dart';

class CabBooking extends Equatable {
  final String id;
  final String bookingId;
  final String userId;
  final String matchId;
  final String pickupLocation;
  final String dropLocation;
  final String hotelName;
  final String hotelAddress;
  final DateTime scheduledTime;
  final CabBookingStatus status;
  final String? driverName;
  final String? driverPhone;
  final String? vehicleNumber;
  final String? otp;
  final double? estimatedFare;
  final DateTime createdAt;
  final DateTime? arrivedAt;
  final DateTime? completedAt;

  const CabBooking({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.matchId,
    required this.pickupLocation,
    required this.dropLocation,
    required this.hotelName,
    required this.hotelAddress,
    required this.scheduledTime,
    required this.status,
    this.driverName,
    this.driverPhone,
    this.vehicleNumber,
    this.otp,
    this.estimatedFare,
    required this.createdAt,
    this.arrivedAt,
    this.completedAt,
  });

  @override
  List<Object?> get props => [
        id,
        bookingId,
        userId,
        matchId,
        pickupLocation,
        dropLocation,
        hotelName,
        hotelAddress,
        scheduledTime,
        status,
        driverName,
        driverPhone,
        vehicleNumber,
        otp,
        estimatedFare,
        createdAt,
        arrivedAt,
        completedAt,
      ];
}

enum CabBookingStatus {
  pending,
  confirmed,
  driverAssigned,
  driverArrived,
  inTransit,
  completed,
  cancelled,
  failed
}

class CabProvider extends Equatable {
  final String id;
  final String name;
  final String apiKey;
  final bool isActive;
  final List<String> supportedCities;

  const CabProvider({
    required this.id,
    required this.name,
    required this.apiKey,
    required this.isActive,
    required this.supportedCities,
  });

  @override
  List<Object> get props => [id, name, apiKey, isActive, supportedCities];
}