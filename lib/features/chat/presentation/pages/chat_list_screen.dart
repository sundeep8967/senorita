import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/themes/premium_theme.dart';
import '../../../../core/navigation/app_router.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> chats = [
      {
        'id': '1',
        'name': 'Emma',
        'lastMessage': 'Hey! How was your day? 😊',
        'time': '2m ago',
        'image': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
        'isOnline': true,
        'unreadCount': 2,
      },
      {
        'id': '2',
        'name': 'Sophia',
        'lastMessage': 'Would love to meet for coffee sometime!',
        'time': '1h ago',
        'image': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
        'isOnline': false,
        'unreadCount': 0,
      },
      {
        'id': '3',
        'name': 'Isabella',
        'lastMessage': 'That restaurant looks amazing! 🍕',
        'time': '3h ago',
        'image': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
        'isOnline': true,
        'unreadCount': 1,
      },
    ];

    return Scaffold(
      backgroundColor: PremiumTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final chat = chats[index];
          return _buildChatItem(context, chat);
        },
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, Map<String, dynamic> chat) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28.r,
              backgroundImage: NetworkImage(chat['image']),
            ),
            if (chat['isOnline'])
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 16.w,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: PremiumTheme.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          chat['name'],
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: PremiumTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          chat['lastMessage'],
          style: TextStyle(
            fontSize: 14.sp,
            color: PremiumTheme.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              chat['time'],
              style: TextStyle(
                fontSize: 12.sp,
                color: PremiumTheme.textSecondary,
              ),
            ),
            if (chat['unreadCount'] > 0) ...[
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: const BoxDecoration(
                  color: PremiumTheme.primaryPink,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${chat['unreadCount']}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRouter.chat,
            arguments: {
              'matchId': chat['id'],
              'matchedUserName': chat['name'],
              'matchedUserPhoto': chat['image'],
              'isOnline': chat['isOnline'],
            },
          );
        },
      ),
    );
  }
}