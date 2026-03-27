import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_notification.dart';
import 'firebase_service.dart';

class AppNotificationService {
  static final AppNotificationService _instance = AppNotificationService._internal();
  factory AppNotificationService() => _instance;
  AppNotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseService _firebaseService = FirebaseService();

  /// Create a new in-app notification
  Future<void> createNotification({
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? data,
  }) async {
    try {
      final notification = AppNotification(
        id: '',
        userId: userId,
        title: title,
        body: body,
        type: type,
        isRead: false,
        createdAt: Timestamp.now(),
        data: data,
      );

      await _firestore
          .collection('notifications')
          .add(notification.toFirestore());

      print('✅ In-app notification created for user: $userId');
    } catch (e) {
      print('❌ Error creating notification: $e');
    }
  }

  /// Get all notifications for current user
  Stream<List<AppNotification>> getNotificationsForUser() {
    final currentUserId = _firebaseService.currentUserId;
    if (currentUserId == null) return Stream.value([]);

    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AppNotification.fromFirestore(doc))
          .toList();
    });
  }

  /// Get unread notification count
  Stream<int> getUnreadCount() {
    final currentUserId = _firebaseService.currentUserId;
    if (currentUserId == null) return Stream.value(0);

    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
      print('✅ Notification marked as read: $notificationId');
    } catch (e) {
      print('❌ Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    final currentUserId = _firebaseService.currentUserId;
    if (currentUserId == null) return;

    try {
      final unreadDocs = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: currentUserId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in unreadDocs.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();

      print('✅ All notifications marked as read');
    } catch (e) {
      print('❌ Error marking all notifications as read: $e');
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
      print('✅ Notification deleted: $notificationId');
    } catch (e) {
      print('❌ Error deleting notification: $e');
    }
  }

  /// Helper: Create meetup request notification
  Future<void> createMeetupRequestNotification({
    required String receiverId,
    required String requesterName,
    required String meetupId,
  }) async {
    await createNotification(
      userId: receiverId,
      title: 'New Meetup Request',
      body: '$requesterName wants to meet you!',
      type: NotificationType.meetupRequest,
      data: {'meetupId': meetupId},
    );
  }

  /// Helper: Create meetup accepted notification
  Future<void> createMeetupAcceptedNotification({
    required String receiverId,
    required String accepterName,
    required String meetupId,
  }) async {
    await createNotification(
      userId: receiverId,
      title: 'Meetup Accepted! 🎉',
      body: '$accepterName accepted your meetup request!',
      type: NotificationType.meetupAccepted,
      data: {'meetupId': meetupId},
    );
  }

  /// Helper: Create meetup declined notification
  Future<void> createMeetupDeclinedNotification({
    required String receiverId,
    required String declinerName,
    required String meetupId,
  }) async {
    await createNotification(
      userId: receiverId,
      title: 'Meetup Declined',
      body: '$declinerName declined your meetup request.',
      type: NotificationType.meetupDeclined,
      data: {'meetupId': meetupId},
    );
  }

  /// Helper: Create new message notification
  Future<void> createNewMessageNotification({
    required String receiverId,
    required String senderName,
    required String messagePreview,
    required String chatRoomId,
  }) async {
    await createNotification(
      userId: receiverId,
      title: 'New message from $senderName',
      body: messagePreview,
      type: NotificationType.newMessage,
      data: {'chatRoomId': chatRoomId},
    );
  }
}
