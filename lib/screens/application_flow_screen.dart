import 'package:flutter/material.dart';
import 'name_step_screen.dart';
import 'age_step_screen.dart';
import 'profession_step_screen.dart';
import 'location_step_screen.dart';

class SenoritaApplicationScreen extends StatefulWidget {
  const SenoritaApplicationScreen({Key? key}) : super(key: key);

  @override
  State<SenoritaApplicationScreen> createState() => _SenoritaApplicationScreenState();
}

class _SenoritaApplicationScreenState extends State<SenoritaApplicationScreen> {
  int _currentStep = 0;
  final PageController _pageController = PageController();
  
  // Controllers for each step
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  
  // Data storage
  String fullName = '';
  String age = '';
  String profession = '';
  String location = '';
  double? latitude;
  double? longitude;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _professionController.dispose();
    _locationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
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

  void _completeApplication() {
    // Store the data
    fullName = _nameController.text;
    age = _ageController.text;
    profession = _professionController.text;
    location = _locationController.text;
    
    _joinSenoritaWithGoogle();
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
              Navigator.pop(context); // Go back to welcome screen
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
          if (_currentStep < 3)
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
              children: List.generate(4, (index) {
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
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
                NameStepScreen(
                  controller: _nameController,
                  onNext: _nextStep,
                ),
                AgeStepScreen(
                  controller: _ageController,
                  onNext: _nextStep,
                ),
                ProfessionStepScreen(
                  controller: _professionController,
                  onNext: _nextStep,
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