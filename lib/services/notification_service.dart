import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// Service to handle push notifications via Supabase Edge Functions
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final SupabaseClient _supabaseClient = SupabaseService.instance.client;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get the current user's FCM token from Firestore
  Future<String?> _getUserFcmToken(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        return data?['fcmToken'] as String?;
      }
      return null;
    } catch (e) {
      print('❌ Error getting FCM token for user $userId: $e');
      return null;
    }
  }

  /// Get current user's authentication token
  Future<String?> _getAuthToken() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ No authenticated user');
        return null;
      }
      return await user.getIdToken();
    } catch (e) {
      print('❌ Error getting auth token: $e');
      return null;
    }
  }

  /// Send a new message notification
  /// Called when a user sends a chat message
  Future<bool> sendMessageNotification({
    required String receiverId,
    required String senderName,
    required String messageContent,
    required String chatRoomId,
  }) async {
    try {
      print('📤 Sending message notification to user: $receiverId');

      // Get receiver's FCM token
      final receiverFcmToken = await _getUserFcmToken(receiverId);
      if (receiverFcmToken == null) {
        print('⚠️ Receiver does not have FCM token, skipping notification');
        return false;
      }

      // Get auth token
      final authToken = await _getAuthToken();
      if (authToken == null) {
        print('❌ Failed to get auth token');
        return false;
      }

      // Call Supabase Edge Function
      final response = await _supabaseClient.functions.invoke(
        'notify-message',
        body: {
          'receiverFcmToken': receiverFcmToken,
          'senderName': senderName,
          'messageContent': messageContent,
          'chatRoomId': chatRoomId,
        },
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.status == 200) {
        print('✅ Message notification sent successfully');
        return true;
      } else {
        print('❌ Failed to send message notification: ${response.status}');
        print('   Response: ${response.data}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending message notification: $e');
      return false;
    }
  }

  /// Send a meetup request notification
  /// Called when a user requests a meetup with another user
  Future<bool> sendMeetupRequestNotification({
    required String receiverId,
    required String requesterName,
    required String meetupId,
  }) async {
    try {
      print('📤 Sending meetup request notification to user: $receiverId');

      // Get receiver's FCM token
      final receiverFcmToken = await _getUserFcmToken(receiverId);
      if (receiverFcmToken == null) {
        print('⚠️ Receiver does not have FCM token, skipping notification');
        return false;
      }

      // Get auth token
      final authToken = await _getAuthToken();
      if (authToken == null) {
        print('❌ Failed to get auth token');
        return false;
      }

      // Call Supabase Edge Function
      final response = await _supabaseClient.functions.invoke(
        'notify-meetup-request',
        body: {
          'receiverFcmToken': receiverFcmToken,
          'requesterName': requesterName,
          'meetupId': meetupId,
        },
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.status == 200) {
        print('✅ Meetup request notification sent successfully');
        return true;
      } else {
        print('❌ Failed to send meetup request notification: ${response.status}');
        print('   Response: ${response.data}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending meetup request notification: $e');
      return false;
    }
  }

  /// Send a meetup accepted notification
  /// Called when a user accepts a meetup request
  Future<bool> sendMeetupAcceptedNotification({
    required String receiverId,
    required String accepterName,
    required String meetupId,
    required String chatRoomId,
  }) async {
    try {
      print('📤 Sending meetup accepted notification to user: $receiverId');

      // Get receiver's FCM token
      final receiverFcmToken = await _getUserFcmToken(receiverId);
      if (receiverFcmToken == null) {
        print('⚠️ Receiver does not have FCM token, skipping notification');
        return false;
      }

      // Get auth token
      final authToken = await _getAuthToken();
      if (authToken == null) {
        print('❌ Failed to get auth token');
        return false;
      }

      // Call Supabase Edge Function
      final response = await _supabaseClient.functions.invoke(
        'notify-meetup-accepted',
        body: {
          'receiverFcmToken': receiverFcmToken,
          'accepterName': accepterName,
          'meetupId': meetupId,
          'chatRoomId': chatRoomId,
        },
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.status == 200) {
        print('✅ Meetup accepted notification sent successfully');
        return true;
      } else {
        print('❌ Failed to send meetup accepted notification: ${response.status}');
        print('   Response: ${response.data}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending meetup accepted notification: $e');
      return false;
    }
  }

  /// Send a custom notification using the generic send-notification function
  Future<bool> sendCustomNotification({
    required String receiverId,
    required String title,
    required String body,
    String? type,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      print('📤 Sending custom notification to user: $receiverId');

      // Get receiver's FCM token
      final receiverFcmToken = await _getUserFcmToken(receiverId);
      if (receiverFcmToken == null) {
        print('⚠️ Receiver does not have FCM token, skipping notification');
        return false;
      }

      // Get auth token
      final authToken = await _getAuthToken();
      if (authToken == null) {
        print('❌ Failed to get auth token');
        return false;
      }

      // Build request body
      final requestBody = {
        'fcmToken': receiverFcmToken,
        'title': title,
        'body': body,
        'type': type ?? 'general',
        'data': additionalData ?? {},
      };

      // Call Supabase Edge Function
      final response = await _supabaseClient.functions.invoke(
        'send-notification',
        body: requestBody,
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.status == 200) {
        print('✅ Custom notification sent successfully');
        return true;
      } else {
        print('❌ Failed to send custom notification: ${response.status}');
        print('   Response: ${response.data}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending custom notification: $e');
      return false;
    }
  }

  /// Check if a user has notifications enabled
  Future<bool> areNotificationsEnabled(String userId) async {
    try {
      final prefsDoc = await _firestore
          .collection('user_preferences')
          .doc(userId)
          .get();

      if (!prefsDoc.exists) return true; // Default to enabled

      final data = prefsDoc.data();
      final notifications = data?['notifications'] as Map<String, dynamic>?;
      
      if (notifications == null) return true;
      
      // Check if any notification type is enabled
      return notifications.values.any((value) => value == true);
    } catch (e) {
      print('❌ Error checking notification preferences: $e');
      return true; // Default to enabled on error
    }
  }

  /// Check if a specific notification type is enabled for a user
  Future<bool> isNotificationTypeEnabled(
    String userId,
    String notificationType,
  ) async {
    try {
      final prefsDoc = await _firestore
          .collection('user_preferences')
          .doc(userId)
          .get();

      if (!prefsDoc.exists) return true; // Default to enabled

      final data = prefsDoc.data();
      final notifications = data?['notifications'] as Map<String, dynamic>?;
      
      if (notifications == null) return true;
      
      return notifications[notificationType] ?? true;
    } catch (e) {
      print('❌ Error checking notification type preference: $e');
      return true; // Default to enabled on error
    }
  }
}
