import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final String id;
  final String name;
  final int age;
  final String bio;
  final List<String> photos;
  final String? profession;
  final List<String> interests;
  final double? distance;
  final String? location;
  final bool isVerified;
  final DateTime lastActive;

  const Profile({
    required this.id,
    required this.name,
    required this.age,
    required this.bio,
    required this.photos,
    this.profession,
    this.interests = const [],
    this.distance,
    this.location,
    this.isVerified = false,
    required this.lastActive,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        age,
        bio,
        photos,
        profession,
        interests,
        distance,
        location,
        isVerified,
        lastActive,
      ];
}

enum SwipeAction { like, pass, superLike }

class SwipeResult extends Equatable {
  final String profileId;
  final SwipeAction action;
  final bool isMatch;
  final String? matchId;

  const SwipeResult({
    required this.profileId,
    required this.action,
    this.isMatch = false,
    this.matchId,
  });

  @override
  List<Object?> get props => [profileId, action, isMatch, matchId];
}