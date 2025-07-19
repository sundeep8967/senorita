import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/profile.dart';
import '../repositories/discovery_repository.dart';

class GetDiscoveryProfiles implements UseCase<List<Profile>, GetDiscoveryProfilesParams> {
  final DiscoveryRepository repository;

  GetDiscoveryProfiles(this.repository);

  @override
  Future<Either<Failure, List<Profile>>> call(GetDiscoveryProfilesParams params) async {
    return await repository.getDiscoveryProfiles(
      page: params.page,
      limit: params.limit,
    );
  }
}

class GetDiscoveryProfilesParams extends Equatable {
  final int page;
  final int limit;

  const GetDiscoveryProfilesParams({
    this.page = 0,
    this.limit = 10,
  });

  @override
  List<Object> get props => [page, limit];
}