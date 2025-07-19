import '../../domain/entities/profile.dart';

class ProfileModel extends Profile {
  const ProfileModel({
    required super.id,
    required super.name,
    required super.age,
    required super.bio,
    required super.photos,
    super.profession,
    super.interests,
    super.distance,
    super.location,
    super.isVerified,
    required super.lastActive,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
      bio: json['bio'] as String,
      photos: (json['photos'] as List<dynamic>).cast<String>(),
      profession: json['profession'] as String?,
      interests: (json['interests'] as List<dynamic>?)?.cast<String>() ?? [],
      distance: (json['distance'] as num?)?.toDouble(),
      location: json['location'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      lastActive: DateTime.parse(json['lastActive'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'bio': bio,
      'photos': photos,
      'profession': profession,
      'interests': interests,
      'distance': distance,
      'location': location,
      'isVerified': isVerified,
      'lastActive': lastActive.toIso8601String(),
    };
  }

  Profile toEntity() {
    return Profile(
      id: id,
      name: name,
      age: age,
      bio: bio,
      photos: photos,
      profession: profession,
      interests: interests,
      distance: distance,
      location: location,
      isVerified: isVerified,
      lastActive: lastActive,
    );
  }
}