import '../../../../models/chat_message.dart';

abstract class ChatRepository {
  Future<String> getOrCreateChatRoom(String otherUserId);
  Future<void> sendMessage(String roomId, ChatMessage message);
  Stream<List<ChatMessage>> getMessagesStream(String roomId);
}
