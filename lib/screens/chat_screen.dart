import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:senorita/features/chat/app/bloc/chat_bloc.dart';
import 'package:senorita/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:senorita/models/chat_message.dart';
import 'package:senorita/services/firebase_service.dart';
import 'package:senorita/widgets/meetup_calendar_widget.dart';
import 'package:senorita/widgets/matched_dates_card.dart';
import 'package:senorita/widgets/verification_code_widget.dart';
import 'package:senorita/widgets/rating_dialog.dart';
import 'package:senorita/widgets/date_selection_prompt.dart';
import 'package:senorita/services/date_selection_service.dart';

class ChatScreen extends StatelessWidget {
  final String otherUserId;
  final String otherUserName;
  final String otherUserAvatar;

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
        otherUserId: otherUserId,
        otherUserName: otherUserName,
        otherUserAvatar: otherUserAvatar,
      ),
    );
  }
}

class ChatView extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final String otherUserAvatar;

  const ChatView({
    Key? key,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserAvatar,
  }) : super(key: key);

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseService _firebaseService = FirebaseService();
  
  String? _chatRoomId;
  String? _currentUserGender;

  @override
  void initState() {
    super.initState();
    _initializeChatData();
  }

  Future<void> _initializeChatData() async {
    try {
      final currentUserId = _firebaseService.currentUserId;
      if (currentUserId == null) return;

      // Get current user's gender from profile
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();
      
      if (userDoc.exists) {
        setState(() {
          _currentUserGender = userDoc.data()?['gender'] ?? 'male';
        });
      }

      // Get or create chat room ID
      final chatRoomQuery = await FirebaseFirestore.instance
          .collection('chat_rooms')
          .where('participantIds', arrayContains: currentUserId)
          .get();

      for (var doc in chatRoomQuery.docs) {
        final participants = List<String>.from(doc.data()['participantIds'] ?? []);
        if (participants.contains(widget.otherUserId)) {
          setState(() {
            _chatRoomId = doc.id;
          });
          
          // Check for pending ratings and deadline
          await _checkPendingRatingAndDeadline(doc.id, currentUserId);
          break;
        }
      }
    } catch (e) {
      print('❌ Error initializing chat data: $e');
    }
  }

  Future<void> _checkPendingRatingAndDeadline(String chatRoomId, String currentUserId) async {
    try {
      final service = DateSelectionService();
      
      // Check deadline first
      await service.checkAndHandleDeadline(chatRoomId);
      
      // Get meetup schedule
      final schedule = await service.getMeetupSchedule(chatRoomId);
      if (schedule == null || schedule.matchedDates.isEmpty) return;

      // Check each confirmed date to see if rating is pending
      final now = DateTime.now();
      for (final matchedDate in schedule.matchedDates) {
        if (!matchedDate.isConfirmed) continue;

        final meetupDate = matchedDate.date;
        final dayAfterMeetup = DateTime(
          meetupDate.year,
          meetupDate.month,
          meetupDate.day + 1,
        );

        // If it's the day after meetup or later, prompt for rating
        if (now.isAfter(dayAfterMeetup)) {
          final isPending = await service.isRatingPending(
            chatRoomId: chatRoomId,
            raterId: currentUserId,
            meetupDate: meetupDate,
          );

          if (isPending && mounted) {
            // Wait a bit before showing dialog
            await Future.delayed(const Duration(milliseconds: 500));
            
            if (mounted) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => RatingDialog(
                  chatRoomId: chatRoomId,
                  raterId: currentUserId,
                  ratedUserId: widget.otherUserId,
                  ratedUserName: widget.otherUserName,
                  meetupDate: meetupDate,
                ),
              );
            }
            break; // Only show one rating dialog at a time
          }
        }
      }
    } catch (e) {
      print('❌ Error checking pending rating: $e');
    }
  }

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
          // Verification code
          if (_chatRoomId != null && _currentUserGender != null)
            VerificationCodeWidget(
              chatRoomId: _chatRoomId!,
              currentUserGender: _currentUserGender!,
            ),
          
          // Date selection prompt (replaces calendar icon)
          if (_chatRoomId != null && _currentUserGender != null)
            DateSelectionPrompt(
              chatRoomId: _chatRoomId!,
              otherUserId: widget.otherUserId,
              currentUserGender: _currentUserGender!,
            ),
          
          // Matched dates card (shown after both select dates)
          if (_chatRoomId != null && _currentUserGender != null)
            MatchedDatesCard(
              chatRoomId: _chatRoomId!,
              currentUserGender: _currentUserGender!,
            ),
          
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
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
            backgroundColor: const Color(0xFF007AFF),
            backgroundImage: widget.otherUserAvatar.isNotEmpty 
                ? NetworkImage(widget.otherUserAvatar) 
                : null,
            child: widget.otherUserAvatar.isEmpty
                ? Text(
                    widget.otherUserName.isNotEmpty 
                        ? widget.otherUserName[0].toUpperCase() 
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.otherUserName,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              overflow: TextOverflow.ellipsis,
            ),
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