import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dating_profile_test_screen.dart';

/// Test runner for the dating profile screen
/// Run this with: flutter run test/screens/run_dating_profile_test.dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const DatingProfileApp());
}