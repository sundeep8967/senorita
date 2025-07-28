import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Auth instance
  static FirebaseAuth get auth => _auth;
  
  // Firestore instance
  static FirebaseFirestore get firestore => _firestore;
  
  // Storage instance
  static FirebaseStorage get storage => _storage;
  
  // Messaging instance
  static FirebaseMessaging get messaging => _messaging;

  // Initialize Firebase services
  static Future<void> initialize() async {
    // Request notification permissions
    await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Get FCM token
    String? token = await _messaging.getToken();
    print('FCM Token: $token');

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // Collections
  static CollectionReference get usersCollection => _firestore.collection('users');
  static CollectionReference get profilesCollection => _firestore.collection('profiles');
  static CollectionReference get matchesCollection => _firestore.collection('matches');
  static CollectionReference get chatsCollection => _firestore.collection('chats');
  static CollectionReference get messagesCollection => _firestore.collection('messages');
  static CollectionReference get paymentsCollection => _firestore.collection('payments');

  // Storage references
  static Reference get profileImagesRef => _storage.ref().child('profile_images');
  static Reference get chatImagesRef => _storage.ref().child('chat_images');
  static Reference get verificationImagesRef => _storage.ref().child('verification_images');
}

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}