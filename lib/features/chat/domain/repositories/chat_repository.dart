import '../../../../models/chat_message.dart';
import '../../../../models/chat_room.dart';

abstract class ChatRepository {
  Future<String> getOrCreateChatRoom(String otherUserId);
  Future<void> sendMessage(String roomId, ChatMessage message);
  Stream<List<ChatMessage>> getMessagesStream(String roomId);
  Stream<List<ChatRoom>> getChatRoomsForUser();
  Future<String> createMeetupChatRoom(String otherUserId, String meetupId);
}
