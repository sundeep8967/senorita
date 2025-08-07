import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Initialize user profile document when they start onboarding
  Future<void> initializeUserProfile() async {
    if (currentUserId == null) return;

    try {
      // First check if user profile already exists
      final userDoc = await _firestore.collection('users').doc(currentUserId).get();
      
      if (userDoc.exists) {
        print('✅ User profile already exists for: $currentUserId');
        
        // Only update basic fields, preserve onboarding status
        await _firestore.collection('users').doc(currentUserId).update({
          'lastUpdated': FieldValue.serverTimestamp(),
          'lastSignIn': FieldValue.serverTimestamp(),
        });
        
        print('✅ User profile updated with last sign-in time');
      } else {
        // Create new profile only for completely new users
        await _firestore.collection('users').doc(currentUserId).set({
          'userId': currentUserId,
          'createdAt': FieldValue.serverTimestamp(),
          'onboardingStarted': true,
          'onboardingCompleted': false,
          'profileCompletionPercentage': 0,
          'lastUpdated': FieldValue.serverTimestamp(),
          'lastSignIn': FieldValue.serverTimestamp(),
        });
        
        print('✅ New user profile created for: $currentUserId');
      }
    } catch (e) {
      print('❌ Error initializing user profile: $e');
      rethrow;
    }
  }

  // Update name step
  Future<void> updateNameStep(String fullName) async {
    if (currentUserId == null) return;

    try {
      await _firestore.collection('users').doc(currentUserId).update({
        'fullName': fullName,
        'nameCompleted': true,
        'profileCompletionPercentage': _calculateCompletionPercentage(['name']),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      print('✅ Name updated: $fullName');
    } catch (e) {
      print('❌ Error updating name: $e');
      rethrow;
    }
  }

  // Update gender step
  Future<void> updateGenderStep(String gender) async {
    if (currentUserId == null) return;

    try {
      await _firestore.collection('users').doc(currentUserId).update({
        'gender': gender,
        'genderCompleted': true,
        'profileCompletionPercentage': _calculateCompletionPercentage(['name', 'gender']),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      print('✅ Gender updated: $gender');
    } catch (e) {
      print('❌ Error updating gender: $e');
      rethrow;
    }
  }

  // Update age step
  Future<void> updateAgeStep(int age) async {
    if (currentUserId == null) return;

    try {
      await _firestore.collection('users').doc(currentUserId).update({
        'age': age,
        'ageCompleted': true,
        'profileCompletionPercentage': _calculateCompletionPercentage(['name', 'gender', 'age']),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      print('✅ Age updated: $age');
    } catch (e) {
      print('❌ Error updating age: $e');
      rethrow;
    }
  }

  // Update profession step
  Future<void> updateProfessionStep(String profession) async {
    if (currentUserId == null) return;

    try {
      await _firestore.collection('users').doc(currentUserId).update({
        'profession': profession,
        'professionCompleted': true,
        'profileCompletionPercentage': _calculateCompletionPercentage(['name', 'gender', 'age', 'profession']),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      print('✅ Profession updated: $profession');
    } catch (e) {
      print('❌ Error updating profession: $e');
      rethrow;
    }
  }

  // Update photos step
  Future<void> updatePhotosStep(List<String> photoUrls) async {
    if (currentUserId == null) return;

    try {
      await _firestore.collection('users').doc(currentUserId).update({
        'photos': photoUrls,
        'photoCount': photoUrls.length,
        'photosCompleted': true,
        'profileCompletionPercentage': _calculateCompletionPercentage(['name', 'gender', 'age', 'profession', 'photos']),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      print('✅ Photos updated: ${photoUrls.length} photos');
    } catch (e) {
      print('❌ Error updating photos: $e');
      rethrow;
    }
  }

  // Update bio step
  Future<void> updateBioStep(String bio) async {
    if (currentUserId == null) return;

    try {
      await _firestore.collection('users').doc(currentUserId).update({
        'bio': bio,
        'bioCompleted': true,
        'profileCompletionPercentage': _calculateCompletionPercentage(['name', 'gender', 'age', 'profession', 'photos', 'bio']),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      print('✅ Bio updated: ${bio.substring(0, bio.length > 50 ? 50 : bio.length)}...');
    } catch (e) {
      print('❌ Error updating bio: $e');
      rethrow;
    }
  }

  // Update location step
  Future<void> updateLocationStep(String location, {double? latitude, double? longitude}) async {
    if (currentUserId == null) return;

    try {
      Map<String, dynamic> locationData = {
        'location': location,
        'locationCompleted': true,
        'profileCompletionPercentage': _calculateCompletionPercentage(['name', 'gender', 'age', 'profession', 'photos', 'bio', 'location']),
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      if (latitude != null && longitude != null) {
        locationData['coordinates'] = GeoPoint(latitude, longitude);
      }

      await _firestore.collection('users').doc(currentUserId).update(locationData);
      
      print('✅ Location updated: $location');
    } catch (e) {
      print('❌ Error updating location: $e');
      rethrow;
    }
  }

  // Complete onboarding
  Future<void> completeOnboarding() async {
    if (currentUserId == null) return;

    try {
      await _firestore.collection('users').doc(currentUserId).update({
        'onboardingCompleted': true,
        'profileCompletionPercentage': 100,
        'onboardingCompletedAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
        'isActive': true,
        'profileStatus': 'active',
      });
      
      print('✅ Onboarding completed successfully!');
    } catch (e) {
      print('❌ Error completing onboarding: $e');
      rethrow;
    }
  }

  // Upload photo to Firebase Storage
  Future<String> uploadPhoto(File photoFile, int photoIndex) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      final String fileName = 'photo_${photoIndex}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage
          .ref()
          .child('profile_images')
          .child(currentUserId!)
          .child(fileName);

      final UploadTask uploadTask = ref.putFile(photoFile);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      print('✅ Photo uploaded: $fileName');
      return downloadUrl;
    } catch (e) {
      print('❌ Error uploading photo: $e');
      rethrow;
    }
  }

  // Upload multiple photos
  Future<List<String>> uploadMultiplePhotos(List<File> photoFiles) async {
    List<String> photoUrls = [];
    
    for (int i = 0; i < photoFiles.length; i++) {
      try {
        final String url = await uploadPhoto(photoFiles[i], i);
        photoUrls.add(url);
      } catch (e) {
        print('❌ Error uploading photo $i: $e');
        // Continue with other photos even if one fails
      }
    }
    
    return photoUrls;
  }

  // Get user profile data
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (currentUserId == null) return null;

    try {
      final DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .get();
      
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('❌ Error getting user profile: $e');
      return null;
    }
  }

  // Listen to user profile changes
  Stream<DocumentSnapshot> getUserProfileStream() {
    if (currentUserId == null) {
      return const Stream.empty();
    }
    
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .snapshots();
  }

  // Calculate completion percentage based on completed steps
  int _calculateCompletionPercentage(List<String> completedSteps) {
    const List<String> allSteps = ['name', 'gender', 'age', 'profession', 'photos', 'bio', 'location'];
    return ((completedSteps.length / allSteps.length) * 100).round();
  }

  // Save onboarding progress (for recovery if user closes app)
  Future<void> saveOnboardingProgress({
    required int currentStep,
    String? tempName,
    String? tempGender,
    String? tempAge,
    String? tempProfession,
    String? tempBio,
    String? tempLocation,
  }) async {
    if (currentUserId == null) return;

    try {
      Map<String, dynamic> progressData = {
        'onboardingCurrentStep': currentStep,
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      // Add temporary data if provided
      if (tempName != null) progressData['tempName'] = tempName;
      if (tempGender != null) progressData['tempGender'] = tempGender;
      if (tempAge != null) progressData['tempAge'] = tempAge;
      if (tempProfession != null) progressData['tempProfession'] = tempProfession;
      if (tempBio != null) progressData['tempBio'] = tempBio;
      if (tempLocation != null) progressData['tempLocation'] = tempLocation;

      await _firestore.collection('users').doc(currentUserId).update(progressData);
      
      print('✅ Onboarding progress saved at step: $currentStep');
    } catch (e) {
      print('❌ Error saving onboarding progress: $e');
    }
  }

  // Initialize notifications and save FCM token
  Future<void> initNotifications() async {
    if (currentUserId == null) return;

    try {
      final messaging = FirebaseMessaging.instance;

      // Request permission
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ User granted notification permission');

        final fcmToken = await messaging.getToken();
        if (fcmToken != null) {
          print('📱 Got FCM Token: $fcmToken');
          // Save the token to the user's profile
          await _firestore.collection('users').doc(currentUserId).update({
            'fcmToken': fcmToken,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
          print('✅ FCM token saved to user profile');
        }

        // Listen for token refreshes and save the new one
        messaging.onTokenRefresh.listen((newToken) {
          print('🔄 FCM token refreshed: $newToken');
          _firestore.collection('users').doc(currentUserId).update({
            'fcmToken': newToken,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        });

      } else {
        print('❌ User declined or has not accepted notification permission');
      }
    } catch (e) {
      print('❌ Error initializing notifications: $e');
    }
  }

  // Create user preferences document
  Future<void> createUserPreferences() async {
    if (currentUserId == null) return;

    try {
      await _firestore.collection('user_preferences').doc(currentUserId).set({
        'userId': currentUserId,
        'ageRange': {'min': 18, 'max': 35},
        'maxDistance': 50, // km
        'showMe': 'everyone', // 'men', 'women', 'everyone'
        'notifications': {
          'newMatches': true,
          'messages': true,
          'likes': true,
          'superLikes': false,
        },
        'privacy': {
          'showAge': true,
          'showDistance': true,
          'showOnline': true,
        },
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      print('✅ User preferences created');
    } catch (e) {
      print('❌ Error creating user preferences: $e');
    }
  }
}