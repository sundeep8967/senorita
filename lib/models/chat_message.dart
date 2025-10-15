import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String messageId;
  final String senderId;
  final String receiverId;
  final String content;
  final Timestamp timestamp;
  final bool isRead;
  final String messageType;

  ChatMessage({
    required this.messageId,
    required this.senderId,
    this.receiverId = '',
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.messageType = 'text',
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      messageId: doc.id,
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      content: data['content'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      isRead: data['isRead'] ?? false,
      messageType: data['messageType'] ?? 'text',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': timestamp,
      'isRead': isRead,
      'messageType': messageType,
    };
  }
}
