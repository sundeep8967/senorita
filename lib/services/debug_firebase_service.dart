import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DebugFirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Test Firebase connection
  static Future<void> testFirebaseConnection() async {
    try {
      print('🔍 Testing Firebase connection...');
      
      // Check Auth
      final User? user = _auth.currentUser;
      print('👤 Current user: ${user?.uid ?? 'No user signed in'}');
      
      // Test Firestore write
      await _firestore.collection('test').doc('connection_test').set({
        'timestamp': FieldValue.serverTimestamp(),
        'message': 'Firebase connection test',
        'platform': 'flutter',
      });
      
      print('✅ Firestore write test successful');
      
      // Test Firestore read
      final doc = await _firestore.collection('test').doc('connection_test').get();
      if (doc.exists) {
        print('✅ Firestore read test successful: ${doc.data()}');
      } else {
        print('❌ Firestore read test failed: Document does not exist');
      }
      
    } catch (e) {
      print('❌ Firebase connection test failed: $e');
    }
  }

  // Create a test user profile
  static Future<void> createTestUserProfile() async {
    try {
      // Sign in anonymously for testing
      final UserCredential userCredential = await _auth.signInAnonymously();
      final String userId = userCredential.user!.uid;
      
      print('👤 Test user created: $userId');
      
      // Create test profile
      await _firestore.collection('users').doc(userId).set({
        'userId': userId,
        'fullName': 'Test User',
        'age': 25,
        'gender': 'Male',
        'profession': 'Developer',
        'bio': 'This is a test bio for debugging purposes.',
        'location': 'Test City',
        'onboardingCompleted': true,
        'profileCompletionPercentage': 100,
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
        'isActive': true,
        'profileStatus': 'active',
      });
      
      print('✅ Test user profile created successfully');
      
      // Verify the data was saved
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        print('✅ Test profile verified: ${doc.data()}');
      } else {
        print('❌ Test profile verification failed');
      }
      
    } catch (e) {
      print('❌ Test user profile creation failed: $e');
    }
  }

  // List all users in Firestore
  static Future<void> listAllUsers() async {
    try {
      print('📋 Listing all users in Firestore...');
      
      final QuerySnapshot snapshot = await _firestore.collection('users').get();
      
      if (snapshot.docs.isEmpty) {
        print('📭 No users found in Firestore');
      } else {
        print('👥 Found ${snapshot.docs.length} users:');
        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          print('  - ${doc.id}: ${data['fullName'] ?? 'No name'} (${data['profileCompletionPercentage'] ?? 0}% complete)');
        }
      }
      
    } catch (e) {
      print('❌ Failed to list users: $e');
    }
  }

  // Check Firestore security rules
  static Future<void> checkFirestoreRules() async {
    try {
      print('🔒 Checking Firestore security rules...');
      
      // Try to write without authentication
      await _firestore.collection('test_rules').doc('test').set({
        'test': 'data',
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      print('⚠️ Warning: Firestore rules allow unauthenticated writes');
      
    } catch (e) {
      if (e.toString().contains('permission-denied')) {
        print('✅ Firestore rules are working (permission denied for unauthenticated writes)');
      } else {
        print('❌ Firestore rules check failed: $e');
      }
    }
  }
}