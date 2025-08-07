import 'package:senorita/services/firebase_service.dart';
import '../../../../models/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final FirebaseService _firebaseService;

  ChatRepositoryImpl(this._firebaseService);

  @override
  Future<String> getOrCreateChatRoom(String otherUserId) {
    return _firebaseService.getOrCreateChatRoom(otherUserId);
  }

  @override
  Stream<List<ChatMessage>> getMessagesStream(String roomId) {
    return _firebaseService.getMessagesStream(roomId);
  }

  @override
  Future<void> sendMessage(String roomId, ChatMessage message) {
    return _firebaseService.sendMessage(roomId, message);
  }
}
