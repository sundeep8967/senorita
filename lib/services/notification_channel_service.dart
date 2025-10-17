import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Service to configure notification channels for Android
class NotificationChannelService {
  static const String _channelId = 'senorita_channel';
  static const String _channelName = 'Senorita Notifications';
  static const String _channelDescription = 'Notifications for messages and meetup requests';

  /// Initialize notification channels for Android
  /// This should be called during app initialization
  static Future<void> initializeChannels() async {
    if (Platform.isAndroid) {
      print('📱 Initializing Android notification channels...');
      
      // For Android 8.0 and above, we need to create notification channels
      // The channel is already configured in AndroidManifest.xml with meta-data
      // But we can also configure it programmatically for more control
      
      // Note: Flutter doesn't have built-in API for creating channels
      // The channel will be created automatically by FCM using the meta-data in AndroidManifest.xml
      // If you need more advanced channel configuration, consider using flutter_local_notifications
      
      print('✅ Notification channel configuration set in AndroidManifest.xml');
      print('   Channel ID: $_channelId');
      print('   Channel Name: $_channelName');
    } else if (Platform.isIOS) {
      print('📱 iOS notification settings configured in Info.plist');
      
      // Request permissions for iOS
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      
      print('✅ iOS notification permission status: ${settings.authorizationStatus}');
    }
  }

  /// Get the default channel ID
  static String get channelId => _channelId;

  /// Get the default channel name
  static String get channelName => _channelName;

  /// Get the default channel description
  static String get channelDescription => _channelDescription;
}
