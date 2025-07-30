import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/cab_booking.dart';

abstract class TransportationRepository {
  Future<Either<Failure, CabBooking>> bookCab({
    required String userId,
    required String meetupId,
    required String pickupLocation,
    required String dropLocation,
    required DateTime scheduledTime,
    CabProvider? preferredProvider,
  });

  Future<Either<Failure, CabBooking>> getCabBooking(String bookingId);

  Future<Either<Failure, List<CabBooking>>> getUserCabBookings(String userId);

  Future<Either<Failure, CabBooking>> updateCabBookingStatus({
    required String bookingId,
    required CabBookingStatus status,
    String? driverName,
    String? driverPhone,
    String? vehicleNumber,
    String? vehicleModel,
    String? trackingId,
  });

  Future<Either<Failure, bool>> cancelCabBooking(String bookingId);

  Future<Either<Failure, List<CabProvider>>> getAvailableProviders({
    required String pickupLocation,
    required String dropLocation,
    required DateTime scheduledTime,
  });

  Future<Either<Failure, double>> estimateFare({
    required String pickupLocation,
    required String dropLocation,
    required CabProvider provider,
  });
}