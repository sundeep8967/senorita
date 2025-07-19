import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/profile.dart';
import '../entities/match.dart';

abstract class DiscoveryRepository {
  Future<Either<Failure, List<Profile>>> getDiscoveryProfiles({
    int page = 0,
    int limit = 10,
  });
  
  Future<Either<Failure, SwipeResult>> swipeProfile({
    required String profileId,
    required SwipeAction action,
  });
  
  Future<Either<Failure, List<Match>>> getMatches();
  
  Future<Either<Failure, void>> reportProfile(String profileId, String reason);
}