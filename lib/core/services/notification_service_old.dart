import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize notification service
  static Future<void> initialize() async {
    // Request permission for notifications
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ User granted permission for notifications');
    } else {
      print('❌ User declined or has not accepted permission');
    }

    // Get FCM token
    String? token = await _messaging.getToken();
    if (token != null) {
      print('📱 FCM Token: $token');
      // TODO: Save token to user profile in database
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
  }

  // Send notification to girl when boy makes paid swipe
  static Future<void> sendMeetupRequestToGirl({
    required String girlUserId,
    required String boyName,
    required String packageName,
    required String hotelName,
    required DateTime scheduledTime,
    required String meetupId,
  }) async {
    try {
      // Get girl's FCM token
      final userDoc = await _firestore.collection('users').doc(girlUserId).get();
      final fcmToken = userDoc.data()?['fcmToken'];

      if (fcmToken == null) {
        print('❌ No FCM token found for user: $girlUserId');
        return;
      }

      // Create notification payload
      final message = RemoteMessage(
        data: {
          'type': 'meetup_request',
          'meetupId': meetupId,
          'boyName': boyName,
          'packageName': packageName,
          'hotelName': hotelName,
          'scheduledTime': scheduledTime.toIso8601String(),
        },
        notification: RemoteNotification(
          title: '💕 New Meetup Request!',
          body: '$boyName wants to meet you at $hotelName for $packageName',
          android: AndroidNotification(
            channelId: 'meetup_requests',
            priority: AndroidNotificationPriority.high,
            importance: AndroidNotificationImportance.high,
            icon: '@drawable/ic_notification',
            color: '#FF6B9D',
          ),
          apple: AppleNotification(
            badge: '1',
            sound: AppleNotificationSound.critical,
          ),
        ),
      );

      // Send notification
      await _messaging.sendMessage(
        to: fcmToken,
        data: message.data,
        notification: message.notification,
      );

      print('✅ Meetup request notification sent to girl');
    } catch (e) {
      print('❌ Failed to send notification: $e');
    }
  }

  // Send notification when girl accepts meetup
  static Future<void> sendMeetupAcceptedToBoy({
    required String boyUserId,
    required String girlName,
    required String hotelName,
    required DateTime scheduledTime,
  }) async {
    try {
      final userDoc = await _firestore.collection('users').doc(boyUserId).get();
      final fcmToken = userDoc.data()?['fcmToken'];

      if (fcmToken == null) return;

      await _messaging.sendMessage(
        to: fcmToken,
        data: {
          'type': 'meetup_accepted',
          'girlName': girlName,
          'hotelName': hotelName,
          'scheduledTime': scheduledTime.toIso8601String(),
        },
        notification: RemoteNotification(
          title: '🎉 Meetup Confirmed!',
          body: '$girlName accepted your request! Meet at $hotelName',
        ),
      );

      print('✅ Meetup accepted notification sent to boy');
    } catch (e) {
      print('❌ Failed to send notification: $e');
    }
  }

  // Send cab booking confirmation
  static Future<void> sendCabBookingConfirmation({
    required String userId,
    required String driverName,
    required String vehicleNumber,
    required String otp,
    required DateTime pickupTime,
  }) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final fcmToken = userDoc.data()?['fcmToken'];

      if (fcmToken == null) return;

      await _messaging.sendMessage(
        to: fcmToken,
        data: {
          'type': 'cab_confirmed',
          'driverName': driverName,
          'vehicleNumber': vehicleNumber,
          'otp': otp,
          'pickupTime': pickupTime.toIso8601String(),
        },
        notification: RemoteNotification(
          title: '🚗 Your FREE Cab is Booked!',
          body: 'Driver: $driverName, Vehicle: $vehicleNumber, OTP: $otp',
        ),
      );

      print('✅ Cab booking confirmation sent');
    } catch (e) {
      print('❌ Failed to send cab notification: $e');
    }
  }

  // Handle foreground messages
  static void _handleForegroundMessage(RemoteMessage message) {
    print('📱 Foreground message received: ${message.notification?.title}');
    
    // Show in-app notification or update UI
    final data = message.data;
    final type = data['type'];

    switch (type) {
      case 'meetup_request':
        _handleMeetupRequest(data);
        break;
      case 'meetup_accepted':
        _handleMeetupAccepted(data);
        break;
      case 'cab_confirmed':
        _handleCabConfirmed(data);
        break;
    }
  }

  // Handle background messages
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('📱 Background message received: ${message.notification?.title}');
    
    // Handle background notification logic
    // Update local database, show notification, etc.
  }

  static void _handleMeetupRequest(Map<String, dynamic> data) {
    // Show meetup request dialog
    print('💕 Meetup request from: ${data['boyName']}');
  }

  static void _handleMeetupAccepted(Map<String, dynamic> data) {
    // Show success message
    print('🎉 Meetup accepted by: ${data['girlName']}');
  }

  static void _handleCabConfirmed(Map<String, dynamic> data) {
    // Show cab details
    print('🚗 Cab confirmed: ${data['driverName']}');
  }

  // Save FCM token to user profile
  static Future<void> saveFCMToken(String userId) async {
    try {
      String? token = await _messaging.getToken();
      if (token != null) {
        await _firestore.collection('users').doc(userId).update({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
        print('✅ FCM token saved for user: $userId');
      }
    } catch (e) {
      print('❌ Failed to save FCM token: $e');
    }
  }
}