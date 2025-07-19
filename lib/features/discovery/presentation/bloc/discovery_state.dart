part of 'discovery_bloc.dart';

abstract class DiscoveryState extends Equatable {
  const DiscoveryState();

  @override
  List<Object?> get props => [];
}

class DiscoveryInitial extends DiscoveryState {}

class DiscoveryLoading extends DiscoveryState {}

class DiscoveryLoaded extends DiscoveryState {
  final List<Profile> profiles;
  final int currentIndex;
  final bool hasMoreProfiles;

  const DiscoveryLoaded({
    required this.profiles,
    required this.currentIndex,
    required this.hasMoreProfiles,
  });

  @override
  List<Object> get props => [profiles, currentIndex, hasMoreProfiles];
}

class MatchFound extends DiscoveryLoaded {
  final Profile matchedProfile;

  const MatchFound({
    required super.profiles,
    required super.currentIndex,
    required super.hasMoreProfiles,
    required this.matchedProfile,
  });

  @override
  List<Object> get props => [...super.props, matchedProfile];
}

class DiscoveryError extends DiscoveryState {
  final String message;

  const DiscoveryError({required this.message});

  @override
  List<Object> get props => [message];
}