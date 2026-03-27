part of 'chat_bloc.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoadInProgress extends ChatState {}

class ChatLoadSuccess extends ChatState {
  final List<ChatMessage> messages;
  final String roomId;

  const ChatLoadSuccess({required this.messages, required this.roomId});

  @override
  List<Object> get props => [messages, roomId];
}

class ChatLoadFailure extends ChatState {
  final String error;

  const ChatLoadFailure({required this.error});

  @override
  List<Object> get props => [error];
}
