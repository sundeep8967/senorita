import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/profile.dart';
import '../../domain/entities/match.dart';
import '../../domain/usecases/get_discovery_profiles.dart';
import '../../domain/usecases/swipe_profile.dart';

part 'discovery_event.dart';
part 'discovery_state.dart';

class DiscoveryBloc extends Bloc<DiscoveryEvent, DiscoveryState> {
  final GetDiscoveryProfiles getDiscoveryProfiles;
  final SwipeProfile swipeProfile;

  DiscoveryBloc({
    required this.getDiscoveryProfiles,
    required this.swipeProfile,
  }) : super(DiscoveryInitial()) {
    on<LoadDiscoveryProfilesEvent>(_onLoadDiscoveryProfiles);
    on<SwipeProfileEvent>(_onSwipeProfile);
    on<LoadMoreProfilesEvent>(_onLoadMoreProfiles);
  }

  Future<void> _onLoadDiscoveryProfiles(
    LoadDiscoveryProfilesEvent event,
    Emitter<DiscoveryState> emit,
  ) async {
    emit(DiscoveryLoading());
    
    final result = await getDiscoveryProfiles(
      GetDiscoveryProfilesParams(page: 0, limit: 10),
    );
    
    result.fold(
      (failure) => emit(DiscoveryError(message: failure.message)),
      (profiles) => emit(DiscoveryLoaded(
        profiles: profiles,
        currentIndex: 0,
        hasMoreProfiles: profiles.length >= 10,
      )),
    );
  }

  Future<void> _onSwipeProfile(
    SwipeProfileEvent event,
    Emitter<DiscoveryState> emit,
  ) async {
    if (state is DiscoveryLoaded) {
      final currentState = state as DiscoveryLoaded;
      
      final result = await swipeProfile(
        SwipeProfileParams(
          profileId: event.profileId,
          action: event.action,
        ),
      );
      
      result.fold(
        (failure) => emit(DiscoveryError(message: failure.message)),
        (swipeResult) {
          if (swipeResult.isMatch) {
            emit(MatchFound(
              profiles: currentState.profiles,
              currentIndex: currentState.currentIndex + 1,
              hasMoreProfiles: currentState.hasMoreProfiles,
              matchedProfile: currentState.profiles[currentState.currentIndex],
            ));
          } else {
            final newIndex = currentState.currentIndex + 1;
            if (newIndex >= currentState.profiles.length && currentState.hasMoreProfiles) {
              // Load more profiles
              add(LoadMoreProfilesEvent());
            } else {
              emit(DiscoveryLoaded(
                profiles: currentState.profiles,
                currentIndex: newIndex,
                hasMoreProfiles: currentState.hasMoreProfiles,
              ));
            }
          }
        },
      );
    }
  }

  Future<void> _onLoadMoreProfiles(
    LoadMoreProfilesEvent event,
    Emitter<DiscoveryState> emit,
  ) async {
    if (state is DiscoveryLoaded) {
      final currentState = state as DiscoveryLoaded;
      
      final result = await getDiscoveryProfiles(
        GetDiscoveryProfilesParams(
          page: (currentState.profiles.length / 10).floor(),
          limit: 10,
        ),
      );
      
      result.fold(
        (failure) => emit(DiscoveryError(message: failure.message)),
        (newProfiles) => emit(DiscoveryLoaded(
          profiles: [...currentState.profiles, ...newProfiles],
          currentIndex: currentState.currentIndex,
          hasMoreProfiles: newProfiles.length >= 10,
        )),
      );
    }
  }
}