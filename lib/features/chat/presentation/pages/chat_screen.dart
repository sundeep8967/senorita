import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/themes/colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../domain/entities/message.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';
import '../../../payment/presentation/pages/payment_screen.dart';

class ChatScreen extends StatefulWidget {
  final String matchId;
  final String matchedUserName;
  final String matchedUserPhoto;
  final bool isOnline;

  const ChatScreen({
    super.key,
    required this.matchId,
    required this.matchedUserName,
    required this.matchedUserPhoto,
    this.isOnline = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    
    // Simulate loading messages
    await Future.delayed(const Duration(seconds: 1));
    
    // Add sample messages
    final sampleMessages = [
      Message(
        id: '1',
        chatId: widget.matchId,
        senderId: 'other_user',
        receiverId: 'current_user',
        content: 'Hi! Thanks for the match! 😊',
        type: MessageType.text,
        sentAt: DateTime.now().subtract(const Duration(hours: 2)),
        readAt: DateTime.now().subtract(const Duration(hours: 1)),
        status: MessageStatus.read,
      ),
      Message(
        id: '2',
        chatId: widget.matchId,
        senderId: 'current_user',
        receiverId: 'other_user',
        content: 'Hello! Nice to meet you! Would you like to meet up for coffee?',
        type: MessageType.text,
        sentAt: DateTime.now().subtract(const Duration(hours: 1)),
        readAt: DateTime.now().subtract(const Duration(minutes: 30)),
        status: MessageStatus.read,
      ),
      Message(
        id: '3',
        chatId: widget.matchId,
        senderId: 'other_user',
        receiverId: 'current_user',
        content: 'That sounds great! I\'d love to meet up ☕',
        type: MessageType.text,
        sentAt: DateTime.now().subtract(const Duration(minutes: 30)),
        status: MessageStatus.delivered,
      ),
    ];
    
    setState(() {
      _messages.addAll(sampleMessages);
      _isLoading = false;
    });
    
    _scrollToBottom();
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: widget.matchId,
      senderId: 'current_user',
      receiverId: 'other_user',
      content: content,
      type: MessageType.text,
      sentAt: DateTime.now(),
      status: MessageStatus.sending,
    );

    setState(() {
      _messages.add(message);
      _messageController.clear();
    });

    _scrollToBottom();

    // Simulate message sending
    Future.delayed(const Duration(seconds: 1), () {
      final index = _messages.indexWhere((m) => m.id == message.id);
      if (index != -1) {
        setState(() {
          _messages[index] = message.copyWith(status: MessageStatus.sent);
        });
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _requestMeetup() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          matchId: widget.matchId,
          matchedUserName: widget.matchedUserName,
          matchedUserPhoto: widget.matchedUserPhoto,
        ),
      ),
    ).then((success) {
      if (success == true) {
        // Add meetup request message
        final meetupMessage = Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          chatId: widget.matchId,
          senderId: 'current_user',
          receiverId: 'other_user',
          content: 'Meetup request sent! 🎉',
          type: MessageType.meetupRequest,
          sentAt: DateTime.now(),
          status: MessageStatus.sent,
        );
        
        setState(() {
          _messages.add(meetupMessage);
        });
        
        _scrollToBottom();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
          ),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      widget.matchedUserPhoto,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.surface,
                          child: Icon(
                            Icons.person,
                            size: 20.sp,
                            color: AppColors.textSecondary,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (widget.isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12.w,
                      height: 12.h,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.matchedUserName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (widget.isOnline)
                    Text(
                      'Online',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.success,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _requestMeetup,
            icon: Icon(
              Icons.restaurant,
              color: AppColors.primary,
            ),
            tooltip: 'Request Meetup',
          ),
          IconButton(
            onPressed: () {
              // Show more options
            },
            icon: Icon(
              Icons.more_vert,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Meetup suggestion banner
          _buildMeetupBanner(),
          
          // Messages list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isMe = message.senderId == 'current_user';
                      final showAvatar = !isMe && 
                          (index == _messages.length - 1 || 
                           _messages[index + 1].senderId != message.senderId);
                      
                      return MessageBubble(
                        message: message,
                        isMe: isMe,
                        showAvatar: showAvatar,
                        avatarUrl: showAvatar ? widget.matchedUserPhoto : null,
                      );
                    },
                  ),
          ),
          
          // Chat input
          ChatInput(
            controller: _messageController,
            onSend: _sendMessage,
            onAttachment: () {
              // Handle attachment
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMeetupBanner() {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.restaurant,
              color: Colors.white,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ready to meet up?',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Request a meetup and make it happen!',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _requestMeetup,
            child: Text(
              'Request',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension MessageCopyWith on Message {
  Message copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? receiverId,
    String? content,
    MessageType? type,
    DateTime? sentAt,
    DateTime? readAt,
    MessageStatus? status,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      type: type ?? this.type,
      sentAt: sentAt ?? this.sentAt,
      readAt: readAt ?? this.readAt,
      status: status ?? this.status,
    );
  }
}