import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'swinglove_test_screen.dart';

/// Test runner for the Swinglove social dating app screen
/// Run this with: flutter run test/screens/run_swinglove_test.dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const SwingLoveApp());
}