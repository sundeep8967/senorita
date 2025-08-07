import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'screens/verification_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/firebase_service.dart';
import 'services/supabase_service.dart';
import 'services/debug_supabase_test.dart';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await SupabaseService.initialize(); // Add this line
    print('✅ Firebase and Supabase initialized successfully');
    
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
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
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
            if (profileCompletionPercentage == 100) {
              print('✅ Profile complete - navigating to home screen');
              FirebaseService().initNotifications();
              if (mounted) {
                setState(() {
                  _homeWidget = const HomeScreen(isLocked: false);
                  _isLoading = false;
                });
              }
            } else {
              print('🔒 Profile incomplete - showing locked home screen');
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