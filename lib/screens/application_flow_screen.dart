import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import 'name_step_screen.dart';
import 'gender_step_screen.dart';
import 'age_step_screen.dart';
import 'profession_step_screen.dart';
import 'photo_upload_step_screen.dart';
import 'bio_step_screen.dart';
import 'location_step_screen.dart';
import 'google_signin_step_screen.dart';
import 'home_screen.dart';
import 'verification_screen.dart';

class SenoritaApplicationScreen extends StatefulWidget {
  const SenoritaApplicationScreen({Key? key}) : super(key: key);

  @override
  State<SenoritaApplicationScreen> createState() => _SenoritaApplicationScreenState();
}

class _SenoritaApplicationScreenState extends State<SenoritaApplicationScreen> {
  int _currentStep = 0;
  final PageController _pageController = PageController();
  final FirebaseService _firebaseService = FirebaseService();
  
  // Controllers for each step
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  
  // Data storage
  String fullName = '';
  String selectedGender = '';
  String age = '';
  String profession = '';
  List<String> uploadedPhotos = [];
  String bio = '';
  String location = '';
  double? latitude;
  double? longitude;

  @override
  void initState() {
    super.initState();
    // Onboarding check is now handled at the app level in main.dart
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _professionController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // Initialize Firebase profile when user starts onboarding
  Future<void> _initializeFirebaseProfile() async {
    try {
      // Check if user is authenticated
      final user = FirebaseAuth.instance.currentUser;
      print('🔍 Current user: ${user?.uid ?? 'No user authenticated'}');
      
      if (user == null) {
        // Sign in anonymously for testing
        print('🔐 Signing in anonymously...');
        await FirebaseAuth.instance.signInAnonymously();
        print('✅ Anonymous sign-in successful');
      }
      
      await _firebaseService.initializeUserProfile();
      print('✅ Firebase profile initialized');
    } catch (e) {
      print('❌ Error initializing Firebase profile: $e');
      _showErrorSnackBar('Failed to initialize profile. Please try again.');
    }
  }

  void _nextStep() async {
    // Save current step data to Firebase before moving to next step
    await _saveCurrentStepData();
    
    if (_currentStep < 7) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeApplication();
    }
  }

  // Save current step data to Firebase
  Future<void> _saveCurrentStepData() async {
    try {
      switch (_currentStep) {
        case 1: // Name step
          if (_nameController.text.trim().isNotEmpty) {
            fullName = _nameController.text.trim();
            await _firebaseService.updateNameStep(fullName);
            _showSuccessSnackBar('Name saved successfully!');
          }
          break;
        case 2: // Gender step
          if (selectedGender.isNotEmpty) {
            await _firebaseService.updateGenderStep(selectedGender);
            _showSuccessSnackBar('Gender preference saved!');
          }
          break;
        case 3: // Age step
          if (_ageController.text.trim().isNotEmpty) {
            age = _ageController.text.trim();
            final ageInt = int.tryParse(age);
            if (ageInt != null && ageInt >= 18) {
              await _firebaseService.updateAgeStep(ageInt);
              _showSuccessSnackBar('Age saved successfully!');
            }
          }
          break;
        case 4: // Profession step
          if (_professionController.text.trim().isNotEmpty) {
            profession = _professionController.text.trim();
            await _firebaseService.updateProfessionStep(profession);
            _showSuccessSnackBar('Profession saved successfully!');
          }
          break;
        case 5: // Photos step
          if (uploadedPhotos.isNotEmpty) {
            await _firebaseService.updatePhotosStep(uploadedPhotos);
            _showSuccessSnackBar('Photos saved successfully!');
          }
          break;
        case 6: // Bio step
          if (_bioController.text.trim().isNotEmpty) {
            bio = _bioController.text.trim();
            await _firebaseService.updateBioStep(bio);
            _showSuccessSnackBar('Bio saved successfully!');
          }
          break;
        case 7: // Location step
          if (_locationController.text.trim().isNotEmpty) {
            location = _locationController.text.trim();
            await _firebaseService.updateLocationStep(
              location,
              latitude: latitude,
              longitude: longitude,
            );
            _showSuccessSnackBar('Location saved successfully!');
          }
          break;
      }
      
      // Save onboarding progress
      await _firebaseService.saveOnboardingProgress(
        currentStep: _currentStep + 1,
        tempName: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : null,
        tempGender: selectedGender.isNotEmpty ? selectedGender : null,
        tempAge: _ageController.text.trim().isNotEmpty ? _ageController.text.trim() : null,
        tempProfession: _professionController.text.trim().isNotEmpty ? _professionController.text.trim() : null,
        tempBio: _bioController.text.trim().isNotEmpty ? _bioController.text.trim() : null,
        tempLocation: _locationController.text.trim().isNotEmpty ? _locationController.text.trim() : null,
      );
      
    } catch (e) {
      print('Error saving step data: $e');
      _showErrorSnackBar('Failed to save data. Please try again.');
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _completeApplication() async {
    // Store the data
    fullName = _nameController.text;
    age = _ageController.text;
    profession = _professionController.text;
    bio = _bioController.text;
    location = _locationController.text;
    
    // Save final step data and complete onboarding
    await _saveCurrentStepData();
    
    try {
      // Complete onboarding in Firebase
      await _firebaseService.completeOnboarding();
      
      // Create user preferences
      await _firebaseService.createUserPreferences();
      
      _showSuccessSnackBar('Profile completed successfully!');
      _joinSenoritaWithGoogle();
    } catch (e) {
      print('Error completing onboarding: $e');
      _showErrorSnackBar('Failed to complete profile. Please try again.');
    }
  }

  void _onGenderSelected(String gender) async {
    selectedGender = gender;
    // Save gender immediately when selected
    try {
      await _firebaseService.updateGenderStep(selectedGender);
      _showSuccessSnackBar('Gender preference saved!');
    } catch (e) {
      print('Error saving gender: $e');
      _showErrorSnackBar('Failed to save gender preference.');
    }
  }

  void _onPhotosSelected(List<String> photos) async {
    uploadedPhotos = photos;
    // Save photos immediately when selected
    try {
      await _firebaseService.updatePhotosStep(uploadedPhotos);
      _showSuccessSnackBar('Photos saved successfully!');
    } catch (e) {
      print('Error saving photos: $e');
      _showErrorSnackBar('Failed to save photos.');
    }
  }

  void _joinSenoritaWithGoogle() async {
    // Show loading state
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Color(0xFF007AFF)),
            const SizedBox(height: 16),
            const Text(
              'Joining Senorita with Google...',
              style: TextStyle(
                color: Color(0xFF1C1C1E),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );

    // Simulate Google sign-in and registration process
    await Future.delayed(const Duration(seconds: 3));

    // Close loading dialog
    Navigator.pop(context);

    // Show success dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          'Welcome to Senorita!',
          style: TextStyle(
            color: Color(0xFF1C1C1E),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Welcome $fullName! You\'re all set. We can now book cabs to your location when needed.',
          style: const TextStyle(
            color: Color(0xFF8E8E93),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const VerificationScreen()),
              );
            },
            child: const Text(
              'Start Exploring',
              style: TextStyle(color: Color(0xFF007AFF)),
            ),
          ),
        ],
      ),
    );
  }

  void _getCurrentLocation() async {
    // Simulate getting current location
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Color(0xFF007AFF)),
            const SizedBox(height: 16),
            const Text(
              'Getting your location...',
              style: TextStyle(
                color: Color(0xFF1C1C1E),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );

    // Simulate location fetch
    await Future.delayed(const Duration(seconds: 2));
    
    // Close loading dialog
    Navigator.pop(context);
    
    // Set mock location data
    setState(() {
      _locationController.text = 'New York, NY, USA';
      latitude = 40.7128;
      longitude = -74.0060;
    });
    
    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Location updated successfully'),
        backgroundColor: const Color(0xFF007AFF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // Helper methods for showing messages
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Debug Firebase function
  Future<void> _debugFirebase() async {
    print('🐛 Starting Firebase debug...');
    
    try {
      // Check current user
      final user = FirebaseAuth.instance.currentUser;
      print('👤 Current user: ${user?.uid ?? 'No user'}');
      print('📅 Device time: ${DateTime.now()}');
      print('📅 Device UTC time: ${DateTime.now().toUtc()}');
      
      if (user == null) {
        await FirebaseAuth.instance.signInAnonymously();
        print('✅ Anonymous sign-in successful');
      }
      
      // Test Firestore write with multiple timestamp formats
      final now = DateTime.now();
      await FirebaseFirestore.instance.collection('debug_test').doc('timestamp_test').set({
        'serverTimestamp': FieldValue.serverTimestamp(),
        'deviceTimestamp': Timestamp.fromDate(now),
        'deviceTimeString': now.toString(),
        'deviceTimeISO': now.toIso8601String(),
        'deviceTimeUTC': now.toUtc().toString(),
        'message': 'Timestamp debug test',
        'userId': FirebaseAuth.instance.currentUser?.uid,
      });
      
      // Read back the data to see what Firebase actually stored
      await Future.delayed(const Duration(seconds: 1)); // Wait for server timestamp
      final doc = await FirebaseFirestore.instance.collection('debug_test').doc('timestamp_test').get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        print('🕐 Server timestamp: ${data['serverTimestamp']}');
        print('🕐 Device timestamp: ${data['deviceTimestamp']}');
        print('🕐 Device time string: ${data['deviceTimeString']}');
        
        // Convert server timestamp back to readable format
        if (data['serverTimestamp'] != null) {
          final serverTime = (data['serverTimestamp'] as Timestamp).toDate();
          print('🕐 Server time converted: $serverTime');
        }
      }
      
      _showSuccessSnackBar('Debug: Timestamp test completed!');
      print('✅ Debug Firestore timestamp test successful');
      
      // List current user data
      final userData = await _firebaseService.getUserProfile();
      print('📋 Current user data: $userData');
      
    } catch (e) {
      print('❌ Debug Firebase failed: $e');
      _showErrorSnackBar('Debug failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7), // iOS light background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF007AFF), size: 20),
          onPressed: _previousStep,
        ),
        actions: [
          // Debug button (remove in production)
          IconButton(
            icon: const Icon(Icons.bug_report, color: Colors.orange),
            onPressed: _debugFirebase,
          ),
          if (_currentStep > 0 && _currentStep < 7 && _currentStep != 5) // Skip not available for photo upload step
            TextButton(
              onPressed: _nextStep,
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: Color(0xFF8E8E93),
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: List.generate(8, (index) {
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: index < 7 ? 8 : 0),
                    height: 4,
                    decoration: BoxDecoration(
                      color: index <= _currentStep 
                          ? const Color(0xFF007AFF) 
                          : const Color(0xFFE5E5EA),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          
          // Page content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                GoogleSignInStepScreen(
                  onNext: _nextStep,
                ),
                NameStepScreen(
                  controller: _nameController,
                  onNext: _nextStep,
                ),
                GenderStepScreen(
                  onNext: _nextStep,
                  onGenderSelected: _onGenderSelected,
                  selectedGender: selectedGender.isNotEmpty ? selectedGender : null,
                ),
                AgeStepScreen(
                  controller: _ageController,
                  onNext: _nextStep,
                ),
                ProfessionStepScreen(
                  controller: _professionController,
                  onNext: _nextStep,
                ),
                PhotoUploadStepScreen(
                  onNext: _nextStep,
                  onPhotosSelected: _onPhotosSelected,
                  selectedPhotos: uploadedPhotos.isNotEmpty ? uploadedPhotos : null,
                ),
                BioStepScreen(
                  controller: _bioController,
                  onComplete: _nextStep,
                ),
                LocationStepScreen(
                  controller: _locationController,
                  onComplete: _completeApplication,
                  onGetCurrentLocation: _getCurrentLocation,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}