import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  final String roomId;
  final List<String> participantIds;
  final String lastMessage;
  final Timestamp lastMessageTimestamp;
  final String lastMessageSenderId;
  final Map<String, int> unreadCounts;
  final String? meetupId;
  final Timestamp? createdAt;

  ChatRoom({
    required this.roomId,
    required this.participantIds,
    this.lastMessage = '',
    required this.lastMessageTimestamp,
    this.lastMessageSenderId = '',
    this.unreadCounts = const {},
    this.meetupId,
    this.createdAt,
  });

  factory ChatRoom.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatRoom(
      roomId: doc.id,
      participantIds: List<String>.from(data['participantIds'] ?? []),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTimestamp: data['lastMessageTimestamp'] ?? Timestamp.now(),
      lastMessageSenderId: data['lastMessageSenderId'] ?? '',
      unreadCounts: Map<String, int>.from(data['unreadCounts'] ?? {}),
      meetupId: data['meetupId'],
      createdAt: data['createdAt'],
    );
  }

  /// Factory for creating ChatRoom from user's chat reference (scalable version)
  factory ChatRoom.fromUserChatReference(
    String roomId, 
    Map<String, dynamic> data, 
    Map<String, Map<String, dynamic>> userProfiles
  ) {
    final otherUserId = data['otherUserId'] as String?;
    final otherUserProfile = otherUserId != null ? userProfiles[otherUserId] : null;
    
    // Build participant IDs from the chat reference
    final currentUserId = data['currentUserId'] as String?; // This might be stored or inferred
    final participantIds = currentUserId != null && otherUserId != null
        ? [currentUserId, otherUserId]
        : <String>[];
    
    // Create unread counts map
    final unreadCount = data['unreadCount'] as int? ?? 0;
    final unreadCounts = currentUserId != null 
        ? <String, int>{currentUserId: unreadCount}
        : <String, int>{};
    
    return ChatRoom(
      roomId: roomId,
      participantIds: participantIds,
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTimestamp: data['lastMessageTimestamp'] ?? Timestamp.now(),
      lastMessageSenderId: data['lastMessageSenderId'] ?? '',
      unreadCounts: unreadCounts,
      meetupId: data['meetupId'],
      createdAt: data['createdAt'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'participantIds': participantIds,
      'lastMessage': lastMessage,
      'lastMessageTimestamp': lastMessageTimestamp,
      'lastMessageSenderId': lastMessageSenderId,
      'unreadCounts': unreadCounts,
      'meetupId': meetupId,
      'createdAt': createdAt,
    };
  }
}
