import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  meetupRequest,
  meetupAccepted,
  meetupDeclined,
  newMessage,
  system,
}

class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final bool isRead;
  final Timestamp createdAt;
  final Map<String, dynamic>? data; // Extra data like meetupId, chatRoomId, etc.

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.isRead = false,
    required this.createdAt,
    this.data,
  });

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: _parseType(data['type'] ?? 'system'),
      isRead: data['isRead'] ?? false,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      data: data['data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'body': body,
      'type': type.toString().split('.').last,
      'isRead': isRead,
      'createdAt': createdAt,
      'data': data,
    };
  }

  static NotificationType _parseType(String typeStr) {
    switch (typeStr) {
      case 'meetupRequest':
        return NotificationType.meetupRequest;
      case 'meetupAccepted':
        return NotificationType.meetupAccepted;
      case 'meetupDeclined':
        return NotificationType.meetupDeclined;
      case 'newMessage':
        return NotificationType.newMessage;
      default:
        return NotificationType.system;
    }
  }

  AppNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    NotificationType? type,
    bool? isRead,
    Timestamp? createdAt,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
    );
  }
}
