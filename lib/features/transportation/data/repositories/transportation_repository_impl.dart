import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/cab_booking.dart';
import '../../domain/repositories/transportation_repository.dart';

class TransportationRepositoryImpl implements TransportationRepository {
  final FirebaseFirestore _firestore;

  TransportationRepositoryImpl(this._firestore);

  @override
  Future<Either<Failure, CabBooking>> bookCabForGirl({
    required String girlUserId,
    required String matchId,
    required String hotelAddress,
    required DateTime pickupTime,
    required Position girlLocation,
  }) async {
    try {
      // 1. Create cab booking record
      final cabBookingDoc = await _firestore.collection('cab_bookings').add({
        'userId': girlUserId,
        'matchId': matchId,
        'pickupLocation': '${girlLocation.latitude},${girlLocation.longitude}',
        'dropLocation': hotelAddress,
        'scheduledTime': Timestamp.fromDate(pickupTime),
        'status': 'pending',
        'estimatedFare': 0.0, // Free for girls
        'createdAt': FieldValue.serverTimestamp(),
        'bookingType': 'girl_pickup',
      });

      // 2. Call Uber/Ola API to book cab
      final cabBooking = await _bookCabWithProvider(
        pickupLocation: '${girlLocation.latitude},${girlLocation.longitude}',
        dropLocation: hotelAddress,
        scheduledTime: pickupTime,
        bookingId: cabBookingDoc.id,
      );

      // 3. Update booking with provider details
      await cabBookingDoc.update({
        'providerBookingId': cabBooking.bookingId,
        'driverName': cabBooking.driverName,
        'driverPhone': cabBooking.driverPhone,
        'vehicleNumber': cabBooking.vehicleNumber,
        'otp': cabBooking.otp,
        'status': 'confirmed',
      });

      return Right(cabBooking);
    } catch (e) {
      return Left(TransportationFailure('Failed to book cab: $e'));
    }
  }

  @override
  Future<Either<Failure, CabBooking>> bookReturnCab({
    required String userId,
    required String matchId,
    required String hotelAddress,
    required String homeAddress,
    required DateTime pickupTime,
  }) async {
    try {
      final cabBookingDoc = await _firestore.collection('cab_bookings').add({
        'userId': userId,
        'matchId': matchId,
        'pickupLocation': hotelAddress,
        'dropLocation': homeAddress,
        'scheduledTime': Timestamp.fromDate(pickupTime),
        'status': 'pending',
        'estimatedFare': 0.0, // Free for girls
        'createdAt': FieldValue.serverTimestamp(),
        'bookingType': 'return_trip',
      });

      final cabBooking = await _bookCabWithProvider(
        pickupLocation: hotelAddress,
        dropLocation: homeAddress,
        scheduledTime: pickupTime,
        bookingId: cabBookingDoc.id,
      );

      await cabBookingDoc.update({
        'providerBookingId': cabBooking.bookingId,
        'status': 'confirmed',
      });

      return Right(cabBooking);
    } catch (e) {
      return Left(TransportationFailure('Failed to book return cab: $e'));
    }
  }

  @override
  Future<Either<Failure, CabBooking>> getCabBookingStatus(String bookingId) async {
    try {
      final doc = await _firestore.collection('cab_bookings').doc(bookingId).get();
      
      if (!doc.exists) {
        return Left(TransportationFailure('Booking not found'));
      }

      final data = doc.data()!;
      final cabBooking = CabBooking(
        id: doc.id,
        bookingId: data['providerBookingId'] ?? '',
        userId: data['userId'],
        matchId: data['matchId'],
        pickupLocation: data['pickupLocation'],
        dropLocation: data['dropLocation'],
        hotelName: data['hotelName'] ?? '',
        hotelAddress: data['dropLocation'],
        scheduledTime: (data['scheduledTime'] as Timestamp).toDate(),
        status: CabBookingStatus.values.firstWhere(
          (e) => e.toString().split('.').last == data['status'],
        ),
        driverName: data['driverName'],
        driverPhone: data['driverPhone'],
        vehicleNumber: data['vehicleNumber'],
        otp: data['otp'],
        estimatedFare: data['estimatedFare']?.toDouble(),
        createdAt: (data['createdAt'] as Timestamp).toDate(),
      );

      return Right(cabBooking);
    } catch (e) {
      return Left(TransportationFailure('Failed to get booking status: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelCabBooking(String bookingId) async {
    try {
      // Cancel with cab provider
      await _cancelCabWithProvider(bookingId);

      // Update status in database
      await _firestore.collection('cab_bookings').doc(bookingId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });

      return const Right(null);
    } catch (e) {
      return Left(TransportationFailure('Failed to cancel booking: $e'));
    }
  }

  // Private methods for cab provider integration
  Future<CabBooking> _bookCabWithProvider({
    required String pickupLocation,
    required String dropLocation,
    required DateTime scheduledTime,
    required String bookingId,
  }) async {
    // TODO: Integrate with real cab provider (Uber/Ola)
    // For now, simulate booking
    
    await Future.delayed(const Duration(seconds: 2)); // Simulate API call
    
    return CabBooking(
      id: bookingId,
      bookingId: 'UBER_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'girl_user_id',
      matchId: 'match_id',
      pickupLocation: pickupLocation,
      dropLocation: dropLocation,
      hotelName: 'Partner Hotel',
      hotelAddress: dropLocation,
      scheduledTime: scheduledTime,
      status: CabBookingStatus.confirmed,
      driverName: 'Rajesh Kumar',
      driverPhone: '+91-9876543210',
      vehicleNumber: 'MH-01-AB-1234',
      otp: '1234',
      estimatedFare: 0.0,
      createdAt: DateTime.now(),
    );
  }

  Future<void> _cancelCabWithProvider(String bookingId) async {
    // TODO: Cancel booking with cab provider
    print('🚗 Cancelling cab booking: $bookingId');
  }
}

abstract class TransportationRepository {
  Future<Either<Failure, CabBooking>> bookCabForGirl({
    required String girlUserId,
    required String matchId,
    required String hotelAddress,
    required DateTime pickupTime,
    required Position girlLocation,
  });

  Future<Either<Failure, CabBooking>> bookReturnCab({
    required String userId,
    required String matchId,
    required String hotelAddress,
    required String homeAddress,
    required DateTime pickupTime,
  });

  Future<Either<Failure, CabBooking>> getCabBookingStatus(String bookingId);

  Future<Either<Failure, void>> cancelCabBooking(String bookingId);
}

class TransportationFailure extends Failure {
  TransportationFailure(String message) : super(message);
}