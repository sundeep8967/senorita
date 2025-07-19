import 'package:equatable/equatable.dart';
import 'user.dart';

class UserProfile extends Equatable {
  final String id;
  final String name;
  final String phoneNumber;
  final String? email;
  final DateTime dateOfBirth;
  final Gender gender;
  final UserType userType;
  final String profilePhoto;
  final String bio;
  final String city;
  final String? area;
  final String? pinCode;
  final UserPreferences preferences;
  final List<String> additionalPhotos;
  final List<String> interests;
  final bool isVerified;
  final bool isKycVerified;
  final String? emergencyContact;
  final CabPreference? cabPreference;
  final List<String> preferredMeetingTimes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.email,
    required this.dateOfBirth,
    required this.gender,
    required this.userType,
    required this.profilePhoto,
    required this.bio,
    required this.city,
    this.area,
    this.pinCode,
    required this.preferences,
    this.additionalPhotos = const [],
    this.interests = const [],
    this.isVerified = false,
    this.isKycVerified = false,
    this.emergencyContact,
    this.cabPreference,
    this.preferredMeetingTimes = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month || 
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  bool get isEligible => age >= 18;

  @override
  List<Object?> get props => [
        id,
        name,
        phoneNumber,
        email,
        dateOfBirth,
        gender,
        userType,
        profilePhoto,
        bio,
        city,
        area,
        pinCode,
        preferences,
        additionalPhotos,
        interests,
        isVerified,
        isKycVerified,
        emergencyContact,
        cabPreference,
        preferredMeetingTimes,
        createdAt,
        updatedAt,
      ];
}

enum CabPreference { ola, uber, any }

class UserPreferences extends Equatable {
  final int minAge;
  final int maxAge;
  final Gender preferredGender;
  final double maxDistance;
  final List<String> preferredCities;
  final List<String> dealBreakers;

  const UserPreferences({
    required this.minAge,
    required this.maxAge,
    required this.preferredGender,
    this.maxDistance = 50.0,
    this.preferredCities = const [],
    this.dealBreakers = const [],
  });

  @override
  List<Object> get props => [
        minAge,
        maxAge,
        preferredGender,
        maxDistance,
        preferredCities,
        dealBreakers,
      ];
}