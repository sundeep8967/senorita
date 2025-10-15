import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:math';

import '../models/chat_message.dart';
import '../models/chat_room.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // CHAT METHODS

  Future<String> getOrCreateChatRoom(String otherUserId) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    List<String> participants = [currentUserId!, otherUserId];
    participants.sort();
    String roomId = participants.join('_');

    final roomDoc = _firestore.collection('chat_rooms').doc(roomId);
    final snapshot = await roomDoc.get();

    if (!snapshot.exists) {
      final newRoom = ChatRoom(
        roomId: roomId,
        participantIds: participants,
        lastMessageTimestamp: Timestamp.now(),
        createdAt: Timestamp.now(),
      );
      await roomDoc.set(newRoom.toFirestore());
    }

    return roomId;
  }

  Future<void> sendMessage(String roomId, ChatMessage message) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    // Get chat room participants for scalable updates
    final roomDoc = await _firestore.collection('chat_rooms').doc(roomId).get();
    if (!roomDoc.exists) throw Exception('Chat room not found');
    
    final participantIds = List<String>.from(roomDoc.data()?['participantIds'] ?? []);
    
    // Use batched writes for better performance and atomicity
    final batch = _firestore.batch();

    // Add message to chat room
    final messageRef = _firestore.collection('chat_rooms').doc(roomId).collection('messages').doc();
    batch.set(messageRef, message.toFirestore());

    // Update main chat room
    final roomRef = _firestore.collection('chat_rooms').doc(roomId);
    batch.update(roomRef, {
      'lastMessage': message.content,
      'lastMessageTimestamp': message.timestamp,
      'lastMessageSenderId': message.senderId,
    });

    // Update user-specific chat references for all participants
    for (final userId in participantIds) {
      final userChatRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('chat_rooms')
          .doc(roomId);
      
      final updateData = {
        'lastMessage': message.content,
        'lastMessageTimestamp': message.timestamp,
        'lastMessageSenderId': message.senderId,
      };
      
      // Increment unread count for receiver, reset for sender
      if (userId != message.senderId) {
        updateData['unreadCount'] = FieldValue.increment(1);
      } else {
        updateData['unreadCount'] = 0; // Reset sender's unread count
      }
      
      batch.update(userChatRef, updateData);
    }

    await batch.commit();
  }

  Stream<List<ChatMessage>> getMessagesStream(String roomId) {
    return _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList();
    });
  }

  /// Gets all chat rooms for the current user (SCALABLE VERSION)
  Stream<List<ChatRoom>> getChatRoomsForUser() {
    if (currentUserId == null) return Stream.value([]);

    // Use user-specific subcollection for better performance with 1000+ users
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('chat_rooms')
        .orderBy('lastMessageTimestamp', descending: true)
        .limit(50) // Limit for performance
        .snapshots()
        .asyncMap((snapshot) async {
      // Batch fetch user profiles to avoid N+1 queries
      final List<String> otherUserIds = snapshot.docs
          .map((doc) => doc.data()['otherUserId'] as String?)
          .where((id) => id != null)
          .cast<String>()
          .toList();
      
      final userProfiles = await _batchGetUserProfiles(otherUserIds);
      
      // Convert to ChatRoom objects with cached user data
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ChatRoom.fromUserChatReference(doc.id, data, userProfiles);
      }).toList();
    });
  }

  /// Batch fetch user profiles to avoid N+1 query problem
  Future<Map<String, Map<String, dynamic>>> _batchGetUserProfiles(List<String> userIds) async {
    final Map<String, Map<String, dynamic>> profiles = {};
    
    if (userIds.isEmpty) return profiles;
    
    // Batch reads in chunks of 10 (Firestore limit)
    for (int i = 0; i < userIds.length; i += 10) {
      final chunk = userIds.skip(i).take(10).toList();
      
      final List<Future<DocumentSnapshot>> futures = chunk.map((userId) =>
          _firestore.collection('users').doc(userId).get()
      ).toList();
      
      final results = await Future.wait(futures);
      for (int j = 0; j < results.length; j++) {
        if (results[j].exists) {
          profiles[chunk[j]] = results[j].data() as Map<String, dynamic>;
        }
      }
    }
    
    return profiles;
  }

  /// Creates a chat room specifically for a meetup between two users (SCALABLE VERSION)
  Future<String> createMeetupChatRoom(String otherUserId, String meetupId) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    List<String> participants = [currentUserId!, otherUserId];
    participants.sort();
    String roomId = participants.join('_');

    final roomDoc = _firestore.collection('chat_rooms').doc(roomId);
    final snapshot = await roomDoc.get();
    final currentTimestamp = Timestamp.now();

    if (!snapshot.exists) {
      // Use batched writes for better performance and atomicity
      final batch = _firestore.batch();
      
      // Create main chat room
      final newRoom = ChatRoom(
        roomId: roomId,
        participantIds: participants,
        lastMessageTimestamp: currentTimestamp,
        createdAt: currentTimestamp,
        meetupId: meetupId,
      );
      batch.set(roomDoc, newRoom.toFirestore());
      
      // Create user-specific chat references for scalable queries
      await _createUserChatReferences(batch, roomId, currentUserId!, otherUserId, meetupId, currentTimestamp);
      
      await batch.commit();
      
      // Add system message after creating room structure
      final systemMessage = ChatMessage(
        messageId: '',
        senderId: 'system',
        receiverId: 'all',
        content: 'You are now connected! Your meetup has been confirmed.',
        timestamp: currentTimestamp,
        messageType: 'system',
      );
      
      await sendMessage(roomId, systemMessage);
      print('✅ Scalable meetup chat room created: $roomId for meetup: $meetupId');
    } else {
      // Update existing room and user references
      final batch = _firestore.batch();
      
      batch.update(roomDoc, {
        'meetupId': meetupId,
        'lastUpdated': currentTimestamp,
      });
      
      // Update user chat references
      batch.update(
        _firestore.collection('users').doc(currentUserId).collection('chat_rooms').doc(roomId),
        {'meetupId': meetupId, 'lastUpdated': currentTimestamp}
      );
      batch.update(
        _firestore.collection('users').doc(otherUserId).collection('chat_rooms').doc(roomId),
        {'meetupId': meetupId, 'lastUpdated': currentTimestamp}
      );
      
      await batch.commit();
      print('✅ Existing scalable chat room updated with meetup: $meetupId');
    }

    return roomId;
  }

  /// Creates user-specific chat references for scalable queries
  Future<void> _createUserChatReferences(WriteBatch batch, String chatRoomId, String user1Id, String user2Id, String meetupId, Timestamp timestamp) async {
    // User 1's chat reference
    batch.set(
      _firestore.collection('users').doc(user1Id).collection('chat_rooms').doc(chatRoomId),
      {
        'chatRoomId': chatRoomId,
        'otherUserId': user2Id,
        'lastMessageTimestamp': timestamp,
        'unreadCount': 0,
        'lastMessage': '',
        'lastMessageSenderId': '',
        'meetupId': meetupId,
        'createdAt': timestamp,
      }
    );
    
    // User 2's chat reference
    batch.set(
      _firestore.collection('users').doc(user2Id).collection('chat_rooms').doc(chatRoomId),
      {
        'chatRoomId': chatRoomId,
        'otherUserId': user1Id,
        'lastMessageTimestamp': timestamp,
        'unreadCount': 0,
        'lastMessage': '',
        'lastMessageSenderId': '',
        'meetupId': meetupId,
        'createdAt': timestamp,
      }
    );
  }


  // USER PROFILE METHODS

  Future<void> initializeUserProfile() async {
    if (currentUserId == null) return;

    try {
      final userDoc = await _firestore.collection('users').doc(currentUserId).get();
      
      if (userDoc.exists) {
        print('✅ User profile already exists for: $currentUserId');
        
        // Check if user has a userCode, if not generate one
        final data = userDoc.data() as Map<String, dynamic>?;
        if (data != null && (data['userCode'] == null || data['userCode'].toString().isEmpty)) {
          final userCode = await _generateUniqueUserCode();
          await _firestore.collection('users').doc(currentUserId).update({
            'userCode': userCode,
            'lastUpdated': FieldValue.serverTimestamp(),
            'lastSignIn': FieldValue.serverTimestamp(),
          });
          print('✅ User code generated: $userCode');
        } else {
          await _firestore.collection('users').doc(currentUserId).update({
            'lastUpdated': FieldValue.serverTimestamp(),
            'lastSignIn': FieldValue.serverTimestamp(),
          });
          print('✅ User profile updated with last sign-in time');
        }
      } else {
        final userCode = await _generateUniqueUserCode();
        await _firestore.collection('users').doc(currentUserId).set({
          'userId': currentUserId,
          'userCode': userCode,
          'createdAt': FieldValue.serverTimestamp(),
          'onboardingStarted': true,
          'onboardingCompleted': false,
          'profileCompletionPercentage': 0,
          'lastUpdated': FieldValue.serverTimestamp(),
          'lastSignIn': FieldValue.serverTimestamp(),
        });
        print('✅ New user profile created for: $currentUserId with code: $userCode');
      }
    } catch (e) {
      print('❌ Error initializing user profile: $e');
      rethrow;
    }
  }

  /// Generates a unique 6-character alphanumeric user code
  Future<String> _generateUniqueUserCode() async {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final Random random = Random();
    int attempts = 0;
    const int maxAttempts = 10;

    while (attempts < maxAttempts) {
      // Generate 6-character code
      String code = '';
      for (int i = 0; i < 6; i++) {
        code += chars[random.nextInt(chars.length)];
      }

      // Check if code already exists
      final querySnapshot = await _firestore
          .collection('users')
          .where('userCode', isEqualTo: code)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('✅ Generated unique user code: $code');
        return code;
      }

      attempts++;
      print('⚠️ Code $code already exists, trying again (attempt $attempts)');
    }

    // Fallback: use timestamp-based code if we can't generate unique one
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final fallbackCode = timestamp.substring(timestamp.length - 6);
    print('⚠️ Using fallback code: $fallbackCode');
    return fallbackCode;
  }

  /// Gets user profile by user code
  Future<Map<String, dynamic>?> getUserProfileByCode(String userCode) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('userCode', isEqualTo: userCode.toUpperCase())
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('❌ Error getting user profile by code: $e');
      return null;
    }
  }

  /// Force generates a new user code for the current user
  Future<void> forceGenerateUserCode() async {
    if (currentUserId == null) {
      print('❌ Cannot generate user code: user not authenticated');
      return;
    }
    
    try {
      print('🔄 Force generating new user code...');
      final userCode = await _generateUniqueUserCode();
      
      await _firestore.collection('users').doc(currentUserId).update({
        'userCode': userCode,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      print('✅ Force generated user code: $userCode');
    } catch (e) {
      print('❌ Error force generating user code: $e');
      rethrow;
    }
  }

  Future<List<QueryDocumentSnapshot>> getPotentialMatches({required String currentUserGender}) async {
    if (currentUserId == null) return [];

    // Define targetGender at the beginning so it's available in all scopes
    // Handle case sensitivity - convert to proper case to match Firebase data
    String targetGender = currentUserGender.toLowerCase() == 'male' ? 'Female' : 'Male';

    try {
      print('🔍 Fetching potential matches for gender: $targetGender');
      
      // First, get all active users with completed onboarding and target gender
      final querySnapshot = await _firestore
          .collection('users')
          .where('gender', isEqualTo: targetGender)
          .where('isActive', isEqualTo: true)
          .where('onboardingCompleted', isEqualTo: true)
          .limit(50)  // Get more documents to filter client-side
          .get();
      
      // Filter out current user client-side to avoid Firestore permission issues
      final filteredDocs = querySnapshot.docs
          .where((doc) => doc.id != currentUserId)
          .take(20)
          .toList();
      
      print('✅ Fetched ${filteredDocs.length} potential matches.');
      return filteredDocs;
    } catch (e) {
      print('❌ Error fetching potential matches: $e');
      // Fallback: try a simpler query without the complex filters
      try {
        print('🔄 Trying fallback query...');
        final fallbackSnapshot = await _firestore
            .collection('users')
            .where('isActive', isEqualTo: true)
            .where('onboardingCompleted', isEqualTo: true)
            .limit(50)
            .get();
        
        // Filter by gender and exclude current user client-side
        final fallbackFiltered = fallbackSnapshot.docs
            .where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final userGender = data['gender']?.toString();
              return userGender == targetGender && doc.id != currentUserId;
            })
            .take(20)
            .toList();
        
        print('✅ Fallback query returned ${fallbackFiltered.length} potential matches.');
        return fallbackFiltered;
      } catch (fallbackError) {
        print('❌ Fallback query also failed: $fallbackError');
        return [];
      }
    }
  }

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

  Future<void> completeOnboarding() async {
    if (currentUserId == null) return;
    try {
      final userDoc = await _firestore.collection('users').doc(currentUserId).get();
      if (!userDoc.exists) {
        print('❌ User document does not exist for completion.');
        return;
      }
      final data = userDoc.data() as Map<String, dynamic>;
      int completedFields = 0;
      int totalFields = 7;
      if (data['nameCompleted'] == true) completedFields++;
      if (data['genderCompleted'] == true) completedFields++;
      if (data['ageCompleted'] == true) completedFields++;
      if (data['professionCompleted'] == true) completedFields++;
      if (data['photosCompleted'] == true) completedFields++;
      if (data['bioCompleted'] == true) completedFields++;
      if (data['locationCompleted'] == true) completedFields++;
      final percentage = ((completedFields / totalFields) * 100).round();
      await _firestore.collection('users').doc(currentUserId).update({
        'onboardingCompleted': true,
        'profileCompletionPercentage': percentage,
        'onboardingCompletedAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
        'isActive': true,
        'profileStatus': 'active',
      });
      print('✅ Onboarding completed successfully! Profile is $percentage% complete.');
    } catch (e) {
      print('❌ Error completing onboarding: $e');
      rethrow;
    }
  }

  Future<String> uploadPhoto(File photoFile, int photoIndex) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    try {
      final String fileName = 'photo_${photoIndex}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref().child('profile_images').child(currentUserId!).child(fileName);
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

  Future<List<String>> uploadMultiplePhotos(List<File> photoFiles) async {
    List<String> photoUrls = [];
    for (int i = 0; i < photoFiles.length; i++) {
      try {
        final String url = await uploadPhoto(photoFiles[i], i);
        photoUrls.add(url);
      } catch (e) {
        print('❌ Error uploading photo $i: $e');
      }
    }
    return photoUrls;
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    if (currentUserId == null) return null;
    try {
      final DocumentSnapshot doc = await _firestore.collection('users').doc(currentUserId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('❌ Error getting user profile: $e');
      return null;
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    if (currentUserId == null) return;
    try {
      await _firestore.collection('users').doc(currentUserId).update(data);
      print('✅ User profile updated successfully');
    } catch (e) {
      print('❌ Error updating user profile: $e');
      rethrow;
    }
  }

  Stream<DocumentSnapshot> getUserProfileStream() {
    if (currentUserId == null) {
      return const Stream.empty();
    }
    return _firestore.collection('users').doc(currentUserId).snapshots();
  }

  int _calculateCompletionPercentage(List<String> completedSteps) {
    const List<String> allSteps = ['name', 'gender', 'age', 'profession', 'photos', 'bio', 'location'];
    return ((completedSteps.length / allSteps.length) * 100).round();
  }

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

  Future<void> initNotifications() async {
    if (currentUserId == null) return;
    try {
      final messaging = FirebaseMessaging.instance;
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
          await _firestore.collection('users').doc(currentUserId).update({
            'fcmToken': fcmToken,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
          print('✅ FCM token saved to user profile');
        }
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

  Future<void> createUserPreferences() async {
    if (currentUserId == null) return;
    try {
      await _firestore.collection('user_preferences').doc(currentUserId).set({
        'userId': currentUserId,
        'ageRange': {'min': 18, 'max': 35},
        'maxDistance': 50,
        'showMe': 'everyone',
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

  // AUTHENTICATION METHODS

  /// Signs out the current user and clears all session data
  Future<void> signOut() async {
    try {
      final String? userId = currentUserId;
      
      if (userId != null) {
        // Update user status to offline before signing out
        await _firestore.collection('users').doc(userId).update({
          'isOnline': false,
          'lastSeen': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        print('✅ User status updated to offline');
      }

      // Sign out from Firebase Auth
      await _auth.signOut();
      print('✅ User signed out successfully');
      
    } catch (e) {
      print('❌ Error during sign out: $e');
      rethrow;
    }
  }

  /// Checks if user is currently authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  /// Gets the current user
  User? get currentUser => _auth.currentUser;

  /// Stream to listen to authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}