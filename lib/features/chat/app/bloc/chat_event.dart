part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

class ChatStarted extends ChatEvent {
  final String otherUserId;

  const ChatStarted({required this.otherUserId});

  @override
  List<Object> get props => [otherUserId];
}

class ChatMessageSent extends ChatEvent {
  final String message;

  const ChatMessageSent({required this.message});

  @override
  List<Object> get props => [message];
}

class _ChatMessagesReceived extends ChatEvent {
  final List<ChatMessage> messages;

  const _ChatMessagesReceived({required this.messages});

  @override
  List<Object> get props => [messages];
}
