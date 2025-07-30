import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/profile.dart';
import '../../domain/entities/match.dart';
import '../../domain/repositories/discovery_repository.dart';
import '../../domain/usecases/paid_swipe_right.dart';
import '../../../payment/domain/entities/payment.dart';
import '../../../meetup/domain/entities/meetup.dart';

class DiscoveryRepositoryImpl implements DiscoveryRepository {
  final FirebaseFirestore _firestore;

  DiscoveryRepositoryImpl(this._firestore);

  @override
  Future<Either<Failure, List<Profile>>> getDiscoveryProfiles({
    int page = 0,
    int limit = 10,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('profiles')
          .where('isActive', isEqualTo: true)
          .limit(limit)
          .skip(page * limit)
          .get();

      final profiles = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Profile(
          id: doc.id,
          name: data['name'] ?? '',
          age: data['age'] ?? 0,
          bio: data['bio'] ?? '',
          photos: List<String>.from(data['photos'] ?? []),
          profession: data['profession'],
          interests: List<String>.from(data['interests'] ?? []),
          distance: data['distance']?.toDouble(),
          location: data['location'],
          isVerified: data['isVerified'] ?? false,
          lastActive: (data['lastActive'] as Timestamp).toDate(),
        );
      }).toList();

      return Right(profiles);
    } catch (e) {
      return Left(ServerFailure('Failed to load profiles: $e'));
    }
  }

  @override
  Future<Either<Failure, SwipeResult>> swipeProfile({
    required String profileId,
    required SwipeAction action,
  }) async {
    try {
      // Record swipe in database
      await _firestore.collection('swipes').add({
        'profileId': profileId,
        'action': action.toString(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Check for mutual like (match)
      final isMatch = await _checkForMatch(profileId);
      String? matchId;
      
      if (isMatch) {
        // Create match record
        final matchDoc = await _firestore.collection('matches').add({
          'profiles': [profileId, 'currentUserId'], // TODO: Get current user ID
          'createdAt': FieldValue.serverTimestamp(),
          'status': 'active',
        });
        matchId = matchDoc.id;
      }

      return Right(SwipeResult(
        profileId: profileId,
        action: action,
        isMatch: isMatch,
        matchId: matchId,
      ));
    } catch (e) {
      return Left(ServerFailure('Failed to swipe profile: $e'));
    }
  }

  @override
  Future<Either<Failure, PaidSwipeResult>> paidSwipeRight({
    required String profileId,
    required PackageType packageType,
    required String selectedHotelId,
    required DateTime preferredDateTime,
    required UserLocation userLocation,
  }) async {
    try {
      // 1. Create payment record
      final paymentDoc = await _firestore.collection('payments').add({
        'profileId': profileId,
        'packageType': packageType.toString(),
        'amount': packageType == PackageType.basic ? 500 : 1000,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. Process payment with Razorpay (TODO: Implement real payment)
      final payment = Payment(
        id: paymentDoc.id,
        orderId: 'order_${DateTime.now().millisecondsSinceEpoch}',
        amount: packageType == PackageType.basic ? 500 : 1000,
        status: PaymentStatus.completed, // TODO: Real payment status
        method: PaymentMethod.razorpay,
        createdAt: DateTime.now(),
        package: MeetupPackage(
          id: packageType == PackageType.basic ? 'coffee' : 'dinner',
          name: packageType == PackageType.basic ? 'Coffee Date' : 'Dinner Date',
          price: packageType == PackageType.basic ? 500 : 1000,
          description: 'Premium meetup experience',
          includes: [],
          type: packageType,
        ),
      );

      // 3. Create meetup request
      final meetupDoc = await _firestore.collection('meetups').add({
        'paymentId': paymentDoc.id,
        'profileId': profileId,
        'hotelId': selectedHotelId,
        'scheduledDateTime': Timestamp.fromDate(preferredDateTime),
        'packageType': packageType.toString(),
        'status': 'waiting_for_girl_response',
        'userLocation': {
          'latitude': userLocation.latitude,
          'longitude': userLocation.longitude,
          'address': userLocation.address,
          'city': userLocation.city,
        },
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 4. Send notification to girl (TODO: Implement push notifications)
      await _sendNotificationToGirl(profileId, meetupDoc.id);

      return Right(PaidSwipeResult(
        profileId: profileId,
        isMatch: false, // Will be true when girl accepts
        payment: payment,
        status: PaidSwipeStatus.waitingForGirlResponse,
        message: 'Payment successful! Waiting for her response.',
      ));
    } catch (e) {
      return Left(ServerFailure('Failed to process paid swipe: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Match>>> getMatches() async {
    try {
      final querySnapshot = await _firestore
          .collection('matches')
          .where('status', isEqualTo: 'active')
          .get();

      final matches = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Match(
          id: doc.id,
          profiles: List<String>.from(data['profiles']),
          createdAt: (data['createdAt'] as Timestamp).toDate(),
          lastMessage: data['lastMessage'],
          lastMessageTime: data['lastMessageTime'] != null
              ? (data['lastMessageTime'] as Timestamp).toDate()
              : null,
        );
      }).toList();

      return Right(matches);
    } catch (e) {
      return Left(ServerFailure('Failed to load matches: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> reportProfile(String profileId, String reason) async {
    try {
      await _firestore.collection('reports').add({
        'profileId': profileId,
        'reason': reason,
        'reportedBy': 'currentUserId', // TODO: Get current user ID
        'createdAt': FieldValue.serverTimestamp(),
      });

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to report profile: $e'));
    }
  }

  Future<bool> _checkForMatch(String profileId) async {
    // TODO: Implement match checking logic
    // Check if the other user has also swiped right
    return false;
  }

  Future<void> _sendNotificationToGirl(String profileId, String meetupId) async {
    // TODO: Implement push notification to girl
    // Use Firebase Cloud Messaging to notify the girl about the paid meetup request
    print('🔔 Sending notification to girl for meetup: $meetupId');
  }
}

class ServerFailure extends Failure {
  ServerFailure(String message) : super(message);
}