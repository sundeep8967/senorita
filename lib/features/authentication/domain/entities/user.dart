import 'package:equatable/equatable.dart';

enum Gender { male, female, other }
enum UserType { male, female }

class User extends Equatable {
  final String id;
  final String? name;
  final String? email;
  final String phoneNumber;
  final String? profilePicture;
  final DateTime? dateOfBirth;
  final String? bio;
  final List<String> photos;
  final List<String> interests;
  final String? profession;
  final Gender? gender;
  final UserType? userType;
  final String? city;
  final String? area;
  final String? pinCode;
  final String? emergencyContact;
  final bool isProfileComplete;
  final bool isKycVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    this.name,
    this.email,
    required this.phoneNumber,
    this.profilePicture,
    this.dateOfBirth,
    this.bio,
    this.photos = const [],
    this.interests = const [],
    this.profession,
    this.gender,
    this.userType,
    this.city,
    this.area,
    this.pinCode,
    this.emergencyContact,
    this.isProfileComplete = false,
    this.isKycVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month || 
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? profilePicture,
    DateTime? dateOfBirth,
    String? bio,
    List<String>? photos,
    List<String>? interests,
    String? profession,
    Gender? gender,
    UserType? userType,
    String? city,
    String? area,
    String? pinCode,
    String? emergencyContact,
    bool? isProfileComplete,
    bool? isKycVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePicture: profilePicture ?? this.profilePicture,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bio: bio ?? this.bio,
      photos: photos ?? this.photos,
      interests: interests ?? this.interests,
      profession: profession ?? this.profession,
      gender: gender ?? this.gender,
      userType: userType ?? this.userType,
      city: city ?? this.city,
      area: area ?? this.area,
      pinCode: pinCode ?? this.pinCode,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      isKycVerified: isKycVerified ?? this.isKycVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phoneNumber,
        profilePicture,
        dateOfBirth,
        bio,
        photos,
        interests,
        profession,
        gender,
        userType,
        city,
        area,
        pinCode,
        emergencyContact,
        isProfileComplete,
        isKycVerified,
        createdAt,
        updatedAt,
      ];
}