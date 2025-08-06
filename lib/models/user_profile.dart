import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String userId;
  final String? fullName;
  final String? gender;
  final int? age;
  final String? profession;
  final List<String>? photos;
  final String? bio;
  final String? location;
  final GeoPoint? coordinates;
  final bool onboardingCompleted;
  final int profileCompletionPercentage;
  final DateTime? createdAt;
  final DateTime? lastUpdated;
  final DateTime? onboardingCompletedAt;
  final bool isActive;
  final String? profileStatus;

  // Onboarding step completion flags
  final bool nameCompleted;
  final bool genderCompleted;
  final bool ageCompleted;
  final bool professionCompleted;
  final bool photosCompleted;
  final bool bioCompleted;
  final bool locationCompleted;

  // Temporary onboarding data (for recovery)
  final int? onboardingCurrentStep;
  final String? tempName;
  final String? tempGender;
  final String? tempAge;
  final String? tempProfession;
  final String? tempBio;
  final String? tempLocation;

  UserProfile({
    required this.userId,
    this.fullName,
    this.gender,
    this.age,
    this.profession,
    this.photos,
    this.bio,
    this.location,
    this.coordinates,
    this.onboardingCompleted = false,
    this.profileCompletionPercentage = 0,
    this.createdAt,
    this.lastUpdated,
    this.onboardingCompletedAt,
    this.isActive = false,
    this.profileStatus,
    this.nameCompleted = false,
    this.genderCompleted = false,
    this.ageCompleted = false,
    this.professionCompleted = false,
    this.photosCompleted = false,
    this.bioCompleted = false,
    this.locationCompleted = false,
    this.onboardingCurrentStep,
    this.tempName,
    this.tempGender,
    this.tempAge,
    this.tempProfession,
    this.tempBio,
    this.tempLocation,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    
    if (data == null) {
      throw Exception('Document data is null');
    }

    return UserProfile(
      userId: doc.id,
      fullName: data['fullName'],
      gender: data['gender'],
      age: data['age'],
      profession: data['profession'],
      photos: data['photos'] != null ? List<String>.from(data['photos']) : null,
      bio: data['bio'],
      location: data['location'],
      coordinates: data['coordinates'],
      onboardingCompleted: data['onboardingCompleted'] ?? false,
      profileCompletionPercentage: data['profileCompletionPercentage'] ?? 0,
      createdAt: data['createdAt']?.toDate(),
      lastUpdated: data['lastUpdated']?.toDate(),
      onboardingCompletedAt: data['onboardingCompletedAt']?.toDate(),
      isActive: data['isActive'] ?? false,
      profileStatus: data['profileStatus'],
      nameCompleted: data['nameCompleted'] ?? false,
      genderCompleted: data['genderCompleted'] ?? false,
      ageCompleted: data['ageCompleted'] ?? false,
      professionCompleted: data['professionCompleted'] ?? false,
      photosCompleted: data['photosCompleted'] ?? false,
      bioCompleted: data['bioCompleted'] ?? false,
      locationCompleted: data['locationCompleted'] ?? false,
      onboardingCurrentStep: data['onboardingCurrentStep'],
      tempName: data['tempName'],
      tempGender: data['tempGender'],
      tempAge: data['tempAge'],
      tempProfession: data['tempProfession'],
      tempBio: data['tempBio'],
      tempLocation: data['tempLocation'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'fullName': fullName,
      'gender': gender,
      'age': age,
      'profession': profession,
      'photos': photos,
      'bio': bio,
      'location': location,
      'coordinates': coordinates,
      'onboardingCompleted': onboardingCompleted,
      'profileCompletionPercentage': profileCompletionPercentage,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'lastUpdated': lastUpdated != null ? Timestamp.fromDate(lastUpdated!) : FieldValue.serverTimestamp(),
      'onboardingCompletedAt': onboardingCompletedAt != null ? Timestamp.fromDate(onboardingCompletedAt!) : null,
      'isActive': isActive,
      'profileStatus': profileStatus,
      'nameCompleted': nameCompleted,
      'genderCompleted': genderCompleted,
      'ageCompleted': ageCompleted,
      'professionCompleted': professionCompleted,
      'photosCompleted': photosCompleted,
      'bioCompleted': bioCompleted,
      'locationCompleted': locationCompleted,
      'onboardingCurrentStep': onboardingCurrentStep,
      'tempName': tempName,
      'tempGender': tempGender,
      'tempAge': tempAge,
      'tempProfession': tempProfession,
      'tempBio': tempBio,
      'tempLocation': tempLocation,
    };
  }

  UserProfile copyWith({
    String? fullName,
    String? gender,
    int? age,
    String? profession,
    List<String>? photos,
    String? bio,
    String? location,
    GeoPoint? coordinates,
    bool? onboardingCompleted,
    int? profileCompletionPercentage,
    DateTime? lastUpdated,
    DateTime? onboardingCompletedAt,
    bool? isActive,
    String? profileStatus,
    bool? nameCompleted,
    bool? genderCompleted,
    bool? ageCompleted,
    bool? professionCompleted,
    bool? photosCompleted,
    bool? bioCompleted,
    bool? locationCompleted,
    int? onboardingCurrentStep,
    String? tempName,
    String? tempGender,
    String? tempAge,
    String? tempProfession,
    String? tempBio,
    String? tempLocation,
  }) {
    return UserProfile(
      userId: userId,
      fullName: fullName ?? this.fullName,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      profession: profession ?? this.profession,
      photos: photos ?? this.photos,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      coordinates: coordinates ?? this.coordinates,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      profileCompletionPercentage: profileCompletionPercentage ?? this.profileCompletionPercentage,
      createdAt: createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      onboardingCompletedAt: onboardingCompletedAt ?? this.onboardingCompletedAt,
      isActive: isActive ?? this.isActive,
      profileStatus: profileStatus ?? this.profileStatus,
      nameCompleted: nameCompleted ?? this.nameCompleted,
      genderCompleted: genderCompleted ?? this.genderCompleted,
      ageCompleted: ageCompleted ?? this.ageCompleted,
      professionCompleted: professionCompleted ?? this.professionCompleted,
      photosCompleted: photosCompleted ?? this.photosCompleted,
      bioCompleted: bioCompleted ?? this.bioCompleted,
      locationCompleted: locationCompleted ?? this.locationCompleted,
      onboardingCurrentStep: onboardingCurrentStep ?? this.onboardingCurrentStep,
      tempName: tempName ?? this.tempName,
      tempGender: tempGender ?? this.tempGender,
      tempAge: tempAge ?? this.tempAge,
      tempProfession: tempProfession ?? this.tempProfession,
      tempBio: tempBio ?? this.tempBio,
      tempLocation: tempLocation ?? this.tempLocation,
    );
  }

  // Helper methods
  bool get hasBasicInfo => nameCompleted && genderCompleted && ageCompleted;
  bool get hasPhotos => photosCompleted && photos != null && photos!.isNotEmpty;
  bool get hasCompleteProfile => onboardingCompleted && profileCompletionPercentage == 100;
  
  List<String> get missingSteps {
    List<String> missing = [];
    if (!nameCompleted) missing.add('Name');
    if (!genderCompleted) missing.add('Gender');
    if (!ageCompleted) missing.add('Age');
    if (!professionCompleted) missing.add('Profession');
    if (!photosCompleted) missing.add('Photos');
    if (!bioCompleted) missing.add('Bio');
    if (!locationCompleted) missing.add('Location');
    return missing;
  }

  @override
  String toString() {
    return 'UserProfile(userId: $userId, fullName: $fullName, completionPercentage: $profileCompletionPercentage%)';
  }
}