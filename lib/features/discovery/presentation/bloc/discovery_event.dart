part of 'discovery_bloc.dart';

abstract class DiscoveryEvent extends Equatable {
  const DiscoveryEvent();

  @override
  List<Object> get props => [];
}

class LoadDiscoveryProfilesEvent extends DiscoveryEvent {}

class SwipeProfileEvent extends DiscoveryEvent {
  final String profileId;
  final SwipeAction action;

  const SwipeProfileEvent({
    required this.profileId,
    required this.action,
  });

  @override
  List<Object> get props => [profileId, action];
}

class LoadMoreProfilesEvent extends DiscoveryEvent {}