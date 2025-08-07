import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:senorita/features/chat/app/bloc/chat_bloc.dart';
import 'package:senorita/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:senorita/models/chat_message.dart';
import 'package:senorita/services/firebase_service.dart';

class ChatScreen extends StatelessWidget {
  final String otherUserId;
  final String otherUserName; // Assuming this is passed from the previous screen
  final String otherUserAvatar; // Assuming this is passed

  const ChatScreen({
    Key? key,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserAvatar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBloc(
        chatRepository: ChatRepositoryImpl(FirebaseService()),
        firebaseAuth: FirebaseAuth.instance,
      )..add(ChatStarted(otherUserId: otherUserId)),
      child: ChatView(
        otherUserName: otherUserName,
        otherUserAvatar: otherUserAvatar,
      ),
    );
  }
}

class ChatView extends StatefulWidget {
  final String otherUserName;
  final String otherUserAvatar;

  const ChatView({
    Key? key,
    required this.otherUserName,
    required this.otherUserAvatar,
  }) : super(key: key);

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      context.read<ChatBloc>().add(ChatMessageSent(message: message));
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is ChatLoadSuccess) {
                  // Scroll to bottom on new message
                  // This needs more robust logic to not scroll if user is scrolled up
                  _scrollController.animateTo(
                    0.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
              },
              builder: (context, state) {
                if (state is ChatLoadInProgress || state is ChatInitial) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ChatLoadFailure) {
                  return Center(child: Text('Error: ${state.error}', style: const TextStyle(color: Colors.red)));
                }
                if (state is ChatLoadSuccess) {
                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      return _buildMessageBubble(message);
                    },
                  );
                }
                return const Center(child: Text('Something went wrong.'));
              },
            ),
          ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(widget.otherUserAvatar), // Use NetworkImage
          ),
          const SizedBox(width: 12),
          Text(
            widget.otherUserName,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final bool isMe = message.senderId == FirebaseAuth.instance.currentUser?.uid;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF007AFF) : Colors.grey[900],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          message.content,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Colors.grey[800]!)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Color(0xFF007AFF)),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}