import 'package:cloud_firestore/cloud_firestore.dart';

/// Enum for notification types
enum NotificationType {
  newMessage,
  meetupRequest,
  meetupAccepted,
  general,
  system;

  String toValue() {
    switch (this) {
      case NotificationType.newMessage:
        return 'new_message';
      case NotificationType.meetupRequest:
        return 'meetup_request';
      case NotificationType.meetupAccepted:
        return 'meetup_accepted';
      case NotificationType.general:
        return 'general';
      case NotificationType.system:
        return 'system';
    }
  }

  static NotificationType fromValue(String value) {
    switch (value) {
      case 'new_message':
        return NotificationType.newMessage;
      case 'meetup_request':
        return NotificationType.meetupRequest;
      case 'meetup_accepted':
        return NotificationType.meetupAccepted;
      case 'system':
        return NotificationType.system;
      default:
        return NotificationType.general;
    }
  }
}

/// Base notification model
class AppNotification {
  final String id;
  final String userId; // Recipient user ID
  final NotificationType type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final bool isRead;
  final String? senderId; // Sender user ID (if applicable)

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    required this.timestamp,
    this.isRead = false,
    this.senderId,
  });

  /// Create from Firestore document
  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: NotificationType.fromValue(data['type'] ?? 'general'),
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      data: Map<String, dynamic>.from(data['data'] ?? {}),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
      senderId: data['senderId'],
    );
  }

  /// Create from FCM message data payload
  factory AppNotification.fromFcmData(Map<String, dynamic> fcmData) {
    return AppNotification(
      id: fcmData['notificationId'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      userId: fcmData['userId'] ?? '',
      type: NotificationType.fromValue(fcmData['type'] ?? 'general'),
      title: fcmData['title'] ?? '',
      body: fcmData['body'] ?? '',
      data: Map<String, dynamic>.from(fcmData),
      timestamp: fcmData['timestamp'] != null
          ? DateTime.parse(fcmData['timestamp'])
          : DateTime.now(),
      isRead: false,
      senderId: fcmData['senderId'],
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type.toValue(),
      'title': title,
      'body': body,
      'data': data,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      if (senderId != null) 'senderId': senderId,
    };
  }

  /// Create a copy with updated fields
  AppNotification copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    bool? isRead,
    String? senderId,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      senderId: senderId ?? this.senderId,
    );
  }
}

/// Message notification model
class MessageNotification {
  final String senderId;
  final String senderName;
  final String chatRoomId;
  final String messageContent;
  final DateTime timestamp;

  MessageNotification({
    required this.senderId,
    required this.senderName,
    required this.chatRoomId,
    required this.messageContent,
    required this.timestamp,
  });

  factory MessageNotification.fromData(Map<String, dynamic> data) {
    return MessageNotification(
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? 'Someone',
      chatRoomId: data['chatRoomId'] ?? '',
      messageContent: data['messageContent'] ?? '',
      timestamp: data['timestamp'] != null
          ? DateTime.parse(data['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'chatRoomId': chatRoomId,
      'messageContent': messageContent,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  String getDisplayText() {
    return messageContent.length > 50
        ? '${messageContent.substring(0, 50)}...'
        : messageContent;
  }
}

/// Meetup request notification model
class MeetupRequestNotification {
  final String requesterId;
  final String requesterName;
  final String meetupId;
  final DateTime timestamp;

  MeetupRequestNotification({
    required this.requesterId,
    required this.requesterName,
    required this.meetupId,
    required this.timestamp,
  });

  factory MeetupRequestNotification.fromData(Map<String, dynamic> data) {
    return MeetupRequestNotification(
      requesterId: data['requesterId'] ?? '',
      requesterName: data['requesterName'] ?? 'Someone',
      meetupId: data['meetupId'] ?? '',
      timestamp: data['timestamp'] != null
          ? DateTime.parse(data['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'requesterId': requesterId,
      'requesterName': requesterName,
      'meetupId': meetupId,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Meetup accepted notification model
class MeetupAcceptedNotification {
  final String accepterId;
  final String accepterName;
  final String meetupId;
  final String chatRoomId;
  final DateTime timestamp;

  MeetupAcceptedNotification({
    required this.accepterId,
    required this.accepterName,
    required this.meetupId,
    required this.chatRoomId,
    required this.timestamp,
  });

  factory MeetupAcceptedNotification.fromData(Map<String, dynamic> data) {
    return MeetupAcceptedNotification(
      accepterId: data['accepterId'] ?? '',
      accepterName: data['accepterName'] ?? 'Someone',
      meetupId: data['meetupId'] ?? '',
      chatRoomId: data['chatRoomId'] ?? '',
      timestamp: data['timestamp'] != null
          ? DateTime.parse(data['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'accepterId': accepterId,
      'accepterName': accepterName,
      'meetupId': meetupId,
      'chatRoomId': chatRoomId,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Notification payload for FCM
class NotificationPayload {
  final String title;
  final String body;
  final NotificationType type;
  final Map<String, dynamic> data;

  NotificationPayload({
    required this.title,
    required this.body,
    required this.type,
    this.data = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'type': type.toValue(),
      'data': data,
    };
  }

  factory NotificationPayload.fromMap(Map<String, dynamic> map) {
    return NotificationPayload(
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: NotificationType.fromValue(map['type'] ?? 'general'),
      data: Map<String, dynamic>.from(map['data'] ?? {}),
    );
  }
}
