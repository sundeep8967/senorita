import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'friends_nearby_test_screen.dart';

/// Test runner for the Friends Nearby screen
/// Run this with: flutter run test/screens/run_friends_nearby_test.dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const FriendsNearbyApp());
}