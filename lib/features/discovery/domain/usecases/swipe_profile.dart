import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/profile.dart';
import '../repositories/discovery_repository.dart';

class SwipeProfile implements UseCase<SwipeResult, SwipeProfileParams> {
  final DiscoveryRepository repository;

  SwipeProfile(this.repository);

  @override
  Future<Either<Failure, SwipeResult>> call(SwipeProfileParams params) async {
    return await repository.swipeProfile(
      profileId: params.profileId,
      action: params.action,
    );
  }
}

class SwipeProfileParams extends Equatable {
  final String profileId;
  final SwipeAction action;

  const SwipeProfileParams({
    required this.profileId,
    required this.action,
  });

  @override
  List<Object> get props => [profileId, action];
}