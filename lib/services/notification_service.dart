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

  // ==================== CALENDAR FEATURE NOTIFICATIONS ====================

  /// Send notification when other user selects dates
  Future<bool> sendDateSelectionNotification({
    required String receiverId,
    required String senderName,
    required int dateCount,
    required String chatRoomId,
  }) async {
    return await sendCustomNotification(
      receiverId: receiverId,
      title: '📅 $senderName selected dates',
      body: '$senderName selected $dateCount available date${dateCount > 1 ? 's' : ''} for your meetup!',
      type: 'date_selection',
      additionalData: {
        'chatRoomId': chatRoomId,
        'action': 'open_calendar',
      },
    );
  }

  /// Send notification when dates match
  Future<bool> sendDateMatchNotification({
    required String receiverId,
    required String otherUserName,
    required int matchCount,
    required String chatRoomId,
  }) async {
    return await sendCustomNotification(
      receiverId: receiverId,
      title: '🎉 You have matching dates!',
      body: 'You and $otherUserName are both available on $matchCount date${matchCount > 1 ? 's' : ''}! Pick a time now.',
      type: 'date_match',
      additionalData: {
        'chatRoomId': chatRoomId,
        'action': 'open_chat',
      },
    );
  }

  /// Send notification when other user picks time
  Future<bool> sendTimeSelectionNotification({
    required String receiverId,
    required String senderName,
    required String time,
    required String date,
    required String chatRoomId,
    required bool isGirl,
  }) async {
    return await sendCustomNotification(
      receiverId: receiverId,
      title: isGirl ? '👑 $senderName picked the time' : '⏰ $senderName confirmed time',
      body: isGirl 
          ? '$senderName chose $time for $date. Pick your preferred time!'
          : '$senderName picked $time for $date. Meetup confirmed!',
      type: 'time_selection',
      additionalData: {
        'chatRoomId': chatRoomId,
        'action': 'open_chat',
      },
    );
  }

  /// Send reminder notification 24h before meetup
  Future<bool> sendMeetupReminderNotification({
    required String receiverId,
    required String otherUserName,
    required String date,
    required String time,
    required String verificationCode,
    required String chatRoomId,
  }) async {
    return await sendCustomNotification(
      receiverId: receiverId,
      title: '🔔 Meetup Tomorrow!',
      body: 'Your meetup with $otherUserName is tomorrow at $time. Your code: $verificationCode',
      type: 'meetup_reminder',
      additionalData: {
        'chatRoomId': chatRoomId,
        'verificationCode': verificationCode,
        'action': 'open_chat',
      },
    );
  }

  /// Send notification requesting rating after meetup
  Future<bool> sendRatingRequestNotification({
    required String receiverId,
    required String otherUserName,
    required String chatRoomId,
  }) async {
    return await sendCustomNotification(
      receiverId: receiverId,
      title: '⭐ How was your date?',
      body: 'Rate your experience with $otherUserName to help our community!',
      type: 'rating_request',
      additionalData: {
        'chatRoomId': chatRoomId,
        'action': 'open_rating',
      },
    );
  }

  /// Send deadline warning notification
  Future<bool> sendDeadlineWarningNotification({
    required String receiverId,
    required String otherUserName,
    required int hoursRemaining,
    required String chatRoomId,
  }) async {
    return await sendCustomNotification(
      receiverId: receiverId,
      title: '⚠️ ${hoursRemaining}h to select dates!',
      body: 'Pick dates with $otherUserName soon or your meetup will be cancelled.',
      type: 'deadline_warning',
      additionalData: {
        'chatRoomId': chatRoomId,
        'action': 'open_calendar',
      },
    );
  }

  /// Send notification when meetup is abandoned
  Future<bool> sendMeetupAbandonedNotification({
    required String receiverId,
    required String otherUserName,
    required String chatRoomId,
  }) async {
    return await sendCustomNotification(
      receiverId: receiverId,
      title: '😔 Meetup Cancelled',
      body: 'Your meetup with $otherUserName was cancelled due to no date selection.',
      type: 'meetup_abandoned',
      additionalData: {
        'chatRoomId': chatRoomId,
      },
    );
  }

  /// Send notification when reschedule is requested
  Future<bool> sendRescheduleRequestNotification({
    required String receiverId,
    required String requesterName,
    required String oldDate,
    required String newDate,
    required String chatRoomId,
  }) async {
    return await sendCustomNotification(
      receiverId: receiverId,
      title: '📅 Reschedule Request',
      body: '$requesterName wants to change $oldDate to $newDate. Approve?',
      type: 'reschedule_request',
      additionalData: {
        'chatRoomId': chatRoomId,
        'action': 'open_chat',
      },
    );
  }

  /// Send notification when reschedule is approved
  Future<bool> sendRescheduleApprovedNotification({
    required String receiverId,
    required String approverName,
    required String newDate,
    required String chatRoomId,
  }) async {
    return await sendCustomNotification(
      receiverId: receiverId,
      title: '✅ Reschedule Approved',
      body: '$approverName approved! Your meetup is now on $newDate.',
      type: 'reschedule_approved',
      additionalData: {
        'chatRoomId': chatRoomId,
        'action': 'open_chat',
      },
    );
  }
}
