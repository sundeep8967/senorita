import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    super.name,
    super.email,
    required super.phoneNumber,
    super.profilePicture,
    super.dateOfBirth,
    super.bio,
    super.photos,
    super.interests,
    super.profession,
    super.gender,
    super.userType,
    super.city,
    super.area,
    super.pinCode,
    super.emergencyContact,
    super.isProfileComplete,
    super.isKycVerified,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String,
      profilePicture: json['profilePicture'] as String?,
      dateOfBirth: json['dateOfBirth'] != null 
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      bio: json['bio'] as String?,
      photos: (json['photos'] as List<dynamic>?)?.cast<String>() ?? [],
      interests: (json['interests'] as List<dynamic>?)?.cast<String>() ?? [],
      profession: json['profession'] as String?,
      gender: json['gender'] != null ? Gender.values.byName(json['gender']) : null,
      userType: json['userType'] != null ? UserType.values.byName(json['userType']) : null,
      city: json['city'] as String?,
      area: json['area'] as String?,
      pinCode: json['pinCode'] as String?,
      emergencyContact: json['emergencyContact'] as String?,
      isProfileComplete: json['isProfileComplete'] as bool? ?? false,
      isKycVerified: json['isKycVerified'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePicture': profilePicture,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'bio': bio,
      'photos': photos,
      'interests': interests,
      'profession': profession,
      'gender': gender?.name,
      'userType': userType?.name,
      'city': city,
      'area': area,
      'pinCode': pinCode,
      'emergencyContact': emergencyContact,
      'isProfileComplete': isProfileComplete,
      'isKycVerified': isKycVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      phoneNumber: user.phoneNumber,
      profilePicture: user.profilePicture,
      dateOfBirth: user.dateOfBirth,
      bio: user.bio,
      photos: user.photos,
      interests: user.interests,
      profession: user.profession,
      gender: user.gender,
      userType: user.userType,
      city: user.city,
      area: user.area,
      pinCode: user.pinCode,
      emergencyContact: user.emergencyContact,
      isProfileComplete: user.isProfileComplete,
      isKycVerified: user.isKycVerified,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }

  User toEntity() {
    return User(
      id: id,
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      profilePicture: profilePicture,
      dateOfBirth: dateOfBirth,
      bio: bio,
      photos: photos,
      interests: interests,
      profession: profession,
      gender: gender,
      userType: userType,
      city: city,
      area: area,
      pinCode: pinCode,
      emergencyContact: emergencyContact,
      isProfileComplete: isProfileComplete,
      isKycVerified: isKycVerified,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}