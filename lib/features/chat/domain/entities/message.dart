import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String id;
  final String chatId;
  final String senderId;
  final String receiverId;
  final String content;
  final MessageType type;
  final DateTime sentAt;
  final DateTime? readAt;
  final MessageStatus status;

  const Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.type,
    required this.sentAt,
    this.readAt,
    required this.status,
  });

  bool get isRead => readAt != null;

  @override
  List<Object?> get props => [
        id,
        chatId,
        senderId,
        receiverId,
        content,
        type,
        sentAt,
        readAt,
        status,
      ];
}

enum MessageType { text, image, meetupRequest, meetupResponse }

enum MessageStatus { sending, sent, delivered, read, failed }

class Chat extends Equatable {
  final String id;
  final String matchId;
  final List<String> participants;
  final Message? lastMessage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int unreadCount;

  const Chat({
    required this.id,
    required this.matchId,
    required this.participants,
    this.lastMessage,
    required this.createdAt,
    required this.updatedAt,
    this.unreadCount = 0,
  });

  @override
  List<Object?> get props => [
        id,
        matchId,
        participants,
        lastMessage,
        createdAt,
        updatedAt,
        unreadCount,
      ];
}