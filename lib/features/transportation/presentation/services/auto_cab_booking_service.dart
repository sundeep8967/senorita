import 'package:geolocator/geolocator.dart';
import '../../domain/entities/cab_booking.dart';
import '../../../meetup/domain/entities/meetup.dart';

/// Service to automatically book cabs for girls when they accept meetup requests
class AutoCabBookingService {
  
  /// Automatically books a cab for the girl from her location to the hotel
  /// This is called when a girl accepts a meetup request
  static Future<CabBooking> bookCabForGirl({
    required String girlUserId,
    required String matchId,
    required Hotel hotel,
    required DateTime meetupTime,
    required Position girlLocation,
  }) async {
    
    // Calculate pickup time (30 minutes before meetup)
    final pickupTime = meetupTime.subtract(const Duration(minutes: 30));
    
    // Create cab booking
    final cabBooking = CabBooking(
      id: 'cab_${DateTime.now().millisecondsSinceEpoch}',
      bookingId: 'SENORITA_${matchId}_GIRL',
      userId: girlUserId,
      matchId: matchId,
      pickupLocation: '${girlLocation.latitude},${girlLocation.longitude}',
      dropLocation: hotel.address,
      hotelName: hotel.name,
      hotelAddress: hotel.address,
      scheduledTime: pickupTime,
      status: CabBookingStatus.pending,
      estimatedFare: 0.0, // Free for girls
      createdAt: DateTime.now(),
    );
    
    // In real implementation:
    // 1. Call Uber/Ola API to book cab
    // 2. Set pickup time 30 minutes before meetup
    // 3. Add special instructions: "Senorita App - Premium Dating Meetup"
    // 4. Mark as "Company Paid" so girl doesn't pay
    // 5. Send booking confirmation to girl
    
    print('🚗 Auto-booking FREE cab for girl:');
    print('   From: ${girlLocation.latitude},${girlLocation.longitude}');
    print('   To: ${hotel.name}, ${hotel.address}');
    print('   Pickup: ${pickupTime.toString()}');
    print('   Status: FREE (Paid by boy)');
    
    return cabBooking;
  }
  
  /// Books return cab for girl after meetup (optional)
  static Future<CabBooking> bookReturnCabForGirl({
    required String girlUserId,
    required String matchId,
    required Hotel hotel,
    required DateTime meetupEndTime,
    required Position girlHomeLocation,
  }) async {
    
    final returnCabBooking = CabBooking(
      id: 'return_cab_${DateTime.now().millisecondsSinceEpoch}',
      bookingId: 'SENORITA_${matchId}_RETURN',
      userId: girlUserId,
      matchId: matchId,
      pickupLocation: hotel.address,
      dropLocation: '${girlHomeLocation.latitude},${girlHomeLocation.longitude}',
      hotelName: hotel.name,
      hotelAddress: hotel.address,
      scheduledTime: meetupEndTime,
      status: CabBookingStatus.pending,
      estimatedFare: 0.0, // Free for girls
      createdAt: DateTime.now(),
    );
    
    print('🚗 Auto-booking FREE return cab for girl:');
    print('   From: ${hotel.name}');
    print('   To: Home location');
    print('   Pickup: ${meetupEndTime.toString()}');
    
    return returnCabBooking;
  }
}