import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    try {
      // Request permission for iOS
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      print('User granted permission: ${settings.authorizationStatus}');

      // Get the token
      String? token = await _messaging.getToken();
      print('FCM Token: $token');

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Received foreground message: ${message.notification?.title}');
        _showLocalNotification(
          message.notification?.title ?? 'New Message',
          message.notification?.body ?? '',
        );
      });

      // Handle background messages
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('Message clicked: ${message.notification?.title}');
      });

    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  Future<void> _showLocalNotification(String title, String body) async {
    // Simple print for now since flutter_local_notifications is disabled
    print('Local notification: $title - $body');
  }

  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  Future<void> sendMeetupRequest({
    required String girlToken,
    required String boyName,
    required String packageType,
    required String venue,
    required String time,
  }) async {
    try {
      print('Would send meetup request notification to: $girlToken');
      print('From: $boyName, Package: $packageType, Venue: $venue, Time: $time');
    } catch (e) {
      print('Error sending meetup request: $e');
    }
  }

  Future<void> sendMeetupAccepted({
    required String boyToken,
    required String girlName,
    required String venue,
    required String time,
  }) async {
    try {
      print('Would send meetup accepted notification to: $boyToken');
      print('From: $girlName, Venue: $venue, Time: $time');
    } catch (e) {
      print('Error sending meetup accepted: $e');
    }
  }

  Future<void> sendCabBookingUpdate({
    required String userToken,
    required String status,
    required String driverName,
    required String vehicleNumber,
  }) async {
    try {
      print('Would send cab update notification to: $userToken');
      print('Status: $status, Driver: $driverName, Vehicle: $vehicleNumber');
    } catch (e) {
      print('Error sending cab update: $e');
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }
}