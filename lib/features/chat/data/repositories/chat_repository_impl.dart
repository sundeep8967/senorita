import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:senorita/services/firebase_service.dart';
import 'package:senorita/services/notification_service.dart';
import '../../../../models/chat_message.dart';
import '../../../../models/chat_room.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final FirebaseService _firebaseService;
  final NotificationService _notificationService;
  final FirebaseFirestore _firestore;

  ChatRepositoryImpl(
    this._firebaseService, {
    NotificationService? notificationService,
    FirebaseFirestore? firestore,
  })  : _notificationService = notificationService ?? NotificationService(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<String> getOrCreateChatRoom(String otherUserId) {
    return _firebaseService.getOrCreateChatRoom(otherUserId);
  }

  @override
  Stream<List<ChatMessage>> getMessagesStream(String roomId) {
    return _firebaseService.getMessagesStream(roomId);
  }

  @override
  Future<void> sendMessage(String roomId, ChatMessage message) async {
    try {
      // Send the message first
      await _firebaseService.sendMessage(roomId, message);
      print('✅ Message sent successfully');

      // Don't send notification for system messages
      if (message.senderId == 'system') {
        print('ℹ️ Skipping notification for system message');
        return;
      }

      // Get sender's profile to fetch name
      final senderProfile = await _firestore
          .collection('users')
          .doc(message.senderId)
          .get();

      if (!senderProfile.exists) {
        print('⚠️ Sender profile not found, skipping notification');
        return;
      }

      final senderData = senderProfile.data() as Map<String, dynamic>;
      final senderName = senderData['fullName'] ?? 'Someone';

      // Send notification to receiver
      print('📤 Attempting to send notification to receiver: ${message.receiverId}');
      
      final notificationSent = await _notificationService.sendMessageNotification(
        receiverId: message.receiverId,
        senderName: senderName,
        messageContent: message.content,
        chatRoomId: roomId,
      );

      if (notificationSent) {
        print('✅ Chat notification sent successfully');
      } else {
        print('⚠️ Chat notification was not sent (user may not have FCM token)');
      }
    } catch (e) {
      print('❌ Error in sendMessage with notification: $e');
      // Don't rethrow - message was sent, notification failure shouldn't break the flow
    }
  }

  @override
  Stream<List<ChatRoom>> getChatRoomsForUser() {
    return _firebaseService.getChatRoomsForUser();
  }

  @override
  Future<String> createMeetupChatRoom(String otherUserId, String meetupId) {
    return _firebaseService.createMeetupChatRoom(otherUserId, meetupId);
  }
}
