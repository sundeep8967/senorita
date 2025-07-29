import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../payment/domain/entities/payment.dart';
import '../../../meetup/domain/entities/meetup.dart';
import '../entities/profile.dart';
import '../repositories/discovery_repository.dart';

class PaidSwipeRight implements UseCase<PaidSwipeResult, PaidSwipeParams> {
  final DiscoveryRepository repository;

  PaidSwipeRight(this.repository);

  @override
  Future<Either<Failure, PaidSwipeResult>> call(PaidSwipeParams params) async {
    return await repository.paidSwipeRight(
      profileId: params.profileId,
      packageType: params.packageType,
      selectedHotelId: params.selectedHotelId,
      preferredDateTime: params.preferredDateTime,
      userLocation: params.userLocation,
    );
  }
}

class PaidSwipeParams extends Equatable {
  final String profileId;
  final PackageType packageType;
  final String selectedHotelId;
  final DateTime preferredDateTime;
  final UserLocation userLocation;

  const PaidSwipeParams({
    required this.profileId,
    required this.packageType,
    required this.selectedHotelId,
    required this.preferredDateTime,
    required this.userLocation,
  });

  @override
  List<Object> get props => [
        profileId,
        packageType,
        selectedHotelId,
        preferredDateTime,
        userLocation,
      ];
}

class PaidSwipeResult extends Equatable {
  final String profileId;
  final bool isMatch;
  final String? matchId;
  final Payment payment;
  final Meetup? meetup; // Only if girl accepts
  final PaidSwipeStatus status;
  final String message;

  const PaidSwipeResult({
    required this.profileId,
    required this.isMatch,
    this.matchId,
    required this.payment,
    this.meetup,
    required this.status,
    required this.message,
  });

  @override
  List<Object?> get props => [
        profileId,
        isMatch,
        matchId,
        payment,
        meetup,
        status,
        message,
      ];
}

enum PaidSwipeStatus {
  paymentProcessing,
  paymentCompleted,
  waitingForGirlResponse,
  meetupConfirmed,
  meetupDeclined,
  paymentFailed,
}

class UserLocation extends Equatable {
  final double latitude;
  final double longitude;
  final String address;
  final String city;

  const UserLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.city,
  });

  @override
  List<Object> get props => [latitude, longitude, address, city];
}