import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/firebase_service.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
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
          print('📝 Onboarding completed: $onboardingCompleted');
          
          if (onboardingCompleted == true) {
            print('✅ User has completed onboarding - navigating to home screen');
            if (mounted) {
              setState(() {
                _homeWidget = const HomeScreen();
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