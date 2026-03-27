import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'screens/verification_screen.dart';
import 'screens/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/firebase_service.dart';
import 'services/supabase_service.dart';
import 'services/debug_supabase_test.dart';
import 'services/notification_channel_service.dart';
import 'models/notification_model.dart';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Global key for navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if not already initialized
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  print('🔔 Background message received!');
  print('   Title: ${message.notification?.title}');
  print('   Body: ${message.notification?.body}');
  print('   Data: ${message.data}');
  
  // Handle the background message
  // You can store it locally, update app badge, etc.
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await SupabaseService.initialize();
    print('✅ Firebase and Supabase initialized successfully');
    
    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    print('✅ Background message handler registered');
    
    // Initialize notification channels
    await NotificationChannelService.initializeChannels();
    print('✅ Notification channels initialized');
    
    // Test Supabase connection
    final testResult = await SupabaseConnectionTest.testConnection();
    SupabaseConnectionTest.printTestResults(testResult);
  } catch (e) {
    print('❌ Initialization failed: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Senorita',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = true;
  Widget _homeWidget = const RayaWelcomeScreen();
  late Stream<User?> _authStateStream;
  StreamSubscription<User?>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _authStateStream = FirebaseAuth.instance.authStateChanges();
    _setupAuthListener();
    _setupNotificationHandlers();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  /// Set up FCM notification handlers for foreground and interaction
  void _setupNotificationHandlers() {
    print('🔔 Setting up notification handlers...');
    
    // Handle foreground messages (when app is open and in use)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('🔔 Foreground message received!');
      print('   Title: ${message.notification?.title}');
      print('   Body: ${message.notification?.body}');
      print('   Data: ${message.data}');
      
      // Show in-app notification
      _showInAppNotification(message);
    });

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('🔔 Notification tapped! (App was in background)');
      print('   Data: ${message.data}');
      
      // Navigate to appropriate screen
      _handleNotificationTap(message);
    });

    // Check if app was opened from a terminated state via notification
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('🔔 App opened from notification! (App was terminated)');
        print('   Data: ${message.data}');
        
        // Navigate to appropriate screen after app loads
        Future.delayed(const Duration(seconds: 2), () {
          _handleNotificationTap(message);
        });
      }
    });
    
    print('✅ Notification handlers set up successfully');
  }

  /// Show in-app notification banner
  void _showInAppNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    // Show a SnackBar with the notification
    final context = navigatorKey.currentContext;
    if (context != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.title ?? 'Notification',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                notification.body ?? '',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF007AFF),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'View',
            textColor: Colors.white,
            onPressed: () {
              _handleNotificationTap(message);
            },
          ),
        ),
      );
    }
  }

  /// Handle notification tap and navigate to appropriate screen
  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    final type = data['type'] as String?;
    
    print('🔔 Handling notification tap - Type: $type');
    
    final context = navigatorKey.currentContext;
    if (context == null) {
      print('⚠️ Navigator context not available yet');
      return;
    }

    try {
      switch (type) {
        case 'new_message':
          // Navigate to chat screen
          final chatRoomId = data['chatRoomId'] as String?;
          final senderName = data['senderName'] as String?;
          final senderId = data['senderId'] as String?;
          
          if (chatRoomId != null && senderName != null && senderId != null) {
            print('📱 Navigating to chat room: $chatRoomId');
            
            // Get sender's avatar (you may need to fetch this from Firestore)
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  otherUserId: senderId,
                  otherUserName: senderName,
                  otherUserAvatar: '', // You can fetch this if needed
                ),
              ),
            );
          }
          break;

        case 'meetup_request':
          // Navigate to notification screen or meetup details
          print('📱 Navigating to meetup request');
          // TODO: Navigate to meetup request screen
          // You can implement this based on your app's navigation structure
          break;

        case 'meetup_accepted':
          // Navigate to chat screen
          final chatRoomId = data['chatRoomId'] as String?;
          final accepterName = data['accepterName'] as String?;
          final accepterId = data['accepterId'] as String?;
          
          if (chatRoomId != null && accepterName != null && accepterId != null) {
            print('📱 Navigating to chat room: $chatRoomId');
            
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  otherUserId: accepterId,
                  otherUserName: accepterName,
                  otherUserAvatar: '', // You can fetch this if needed
                ),
              ),
            );
          }
          break;

        default:
          print('⚠️ Unknown notification type: $type');
      }
    } catch (e) {
      print('❌ Error handling notification tap: $e');
    }
  }

  void _setupAuthListener() {
    print('🔍 Setting up authentication listener...');
    
    _authSubscription = _authStateStream.listen((User? user) async {
      await _handleAuthStateChange(user);
    });
    
    // Also check current user immediately
    _handleAuthStateChange(FirebaseAuth.instance.currentUser);
  }

  Future<void> _handleAuthStateChange(User? user) async {
    try {
      if (user != null) {
        print('✅ User authenticated: ${user.uid}');
        
        // Add a small delay to ensure Firebase operations are ready
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Get user profile from Firebase
        final userData = await _firebaseService.getUserProfile();
        print('📋 User data retrieved: ${userData != null ? "Found" : "Not found"}');
        
        if (userData != null) {
          final onboardingCompleted = userData['onboardingCompleted'] ?? false;
          final verificationCompleted = userData['verificationCompleted'] ?? false;
          
          print('📝 Onboarding completed: $onboardingCompleted');
          print('🔐 Verification completed: $verificationCompleted');
          
          final profileCompletionPercentage = userData['profileCompletionPercentage'] ?? 0;
          print('📊 Profile completion: $profileCompletionPercentage%');

          if (onboardingCompleted == true && verificationCompleted == true) {
            // User is onboarded and verified, now check profile completion
            // Check if essential profile data exists instead of just completion percentage
            bool hasEssentialData = _hasEssentialProfileData(userData);
            
            if (hasEssentialData) {
              print('✅ Profile has essential data - navigating to home screen');
              FirebaseService().initNotifications();
              if (mounted) {
                setState(() {
                  _homeWidget = const HomeScreen(isLocked: false);
                  _isLoading = false;
                });
              }
            } else {
              print('🔒 Profile missing essential data - showing locked home screen');
              if (mounted) {
                setState(() {
                  _homeWidget = const HomeScreen(isLocked: true);
                  _isLoading = false;
                });
              }
            }
            return;
          } else if (onboardingCompleted == true && verificationCompleted != true) {
            print('🔐 User completed onboarding but needs verification - showing verification screen');
            print('🔐 Verification status: $verificationCompleted (forcing verification screen)');
            if (mounted) {
              setState(() {
                _homeWidget = const VerificationScreen();
                _isLoading = false;
              });
            }
            return;
          }
        }
        
        print('📝 User needs to complete onboarding - showing welcome screen');
        if (mounted) {
          setState(() {
            _homeWidget = const RayaWelcomeScreen();
            _isLoading = false;
          });
        }
      } else {
        print('❌ User not authenticated - showing welcome screen');
        if (mounted) {
          setState(() {
            _homeWidget = const RayaWelcomeScreen();
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('❌ Error handling auth state change: $e');
      if (mounted) {
        setState(() {
          _homeWidget = const RayaWelcomeScreen();
          _isLoading = false;
        });
      }
    }
  }

  // Check if user has essential profile data (instead of completion flags)
  bool _hasEssentialProfileData(Map<String, dynamic> userData) {
    // Check for essential data that should exist for the app to function
    bool hasName = userData['fullName'] != null && userData['fullName'].toString().trim().isNotEmpty;
    bool hasAge = userData['age'] != null && userData['age'] is int && userData['age'] > 0;
    bool hasGender = userData['gender'] != null && userData['gender'].toString().trim().isNotEmpty;
    
    // Optional but recommended fields
    bool hasLocation = userData['location'] != null && userData['location'].toString().trim().isNotEmpty;
    bool hasProfession = userData['profession'] != null && userData['profession'].toString().trim().isNotEmpty;
    
    print('📊 Profile data check:');
    print('   Name: $hasName (${userData['fullName']})');
    print('   Age: $hasAge (${userData['age']})');
    print('   Gender: $hasGender (${userData['gender']})');
    print('   Location: $hasLocation (${userData['location']})');
    print('   Profession: $hasProfession (${userData['profession']})');
    
    // Require at least name, age, and gender to unlock
    return hasName && hasAge && hasGender;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1a1a2e),
                Color(0xFF16213e),
                Color(0xFF0f3460),
              ],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                SizedBox(height: 20),
                Text(
                  'Loading...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return _homeWidget;
  }
}