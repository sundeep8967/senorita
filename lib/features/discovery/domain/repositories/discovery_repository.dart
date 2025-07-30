import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/profile.dart';
import '../entities/match.dart';
import '../usecases/paid_swipe_right.dart';

abstract class DiscoveryRepository {
  Future<Either<Failure, List<Profile>>> getDiscoveryProfiles({
    int page = 0,
    int limit = 10,
  });
  
  Future<Either<Failure, SwipeResult>> swipeProfile({
    required String profileId,
    required SwipeAction action,
  });
  
  Future<Either<Failure, PaidSwipeResult>> paidSwipeRight({
    required String profileId,
    required String packageType,
    required String selectedHotelId,
    required DateTime preferredDateTime,
    required Map<String, dynamic> userLocation,
  });
  
  Future<Either<Failure, List<Match>>> getMatches();
  
  Future<Either<Failure, void>> reportProfile(String profileId, String reason);
}