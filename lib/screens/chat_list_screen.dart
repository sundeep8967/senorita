import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Messages',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            margin: const EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: Colors.white.withOpacity(0.7),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Search messages...',
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Chat list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _getDummyChats().length,
              itemBuilder: (context, index) {
                final chat = _getDummyChats()[index];
                return _buildChatItem(context, chat);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, Map<String, dynamic> chat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                // TODO: Navigate to specific chat
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Opening chat with ${chat['name']}'),
                    backgroundColor: Colors.blue.shade600,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: chat['avatarColors'],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        chat['name'][0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Chat details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              chat['name'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              chat['time'],
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                chat['lastMessage'],
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (chat['unreadCount'] > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade500,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  chat['unreadCount'].toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getDummyChats() {
    return [
      {
        'name': 'Emma Thompson',
        'lastMessage': 'Hey! How was your day? 😊',
        'time': '2m ago',
        'unreadCount': 2,
        'avatarColors': [Colors.pink.shade400, Colors.purple.shade600],
      },
      {
        'name': 'Sarah Wilson',
        'lastMessage': 'Looking forward to our coffee date!',
        'time': '15m ago',
        'unreadCount': 0,
        'avatarColors': [Colors.blue.shade400, Colors.teal.shade600],
      },
      {
        'name': 'Jessica Lee',
        'lastMessage': 'That restaurant looks amazing 🍕',
        'time': '1h ago',
        'unreadCount': 1,
        'avatarColors': [Colors.orange.shade400, Colors.red.shade600],
      },
      {
        'name': 'Michelle Davis',
        'lastMessage': 'Thanks for the recommendation!',
        'time': '3h ago',
        'unreadCount': 0,
        'avatarColors': [Colors.green.shade400, Colors.teal.shade600],
      },
      {
        'name': 'Ashley Brown',
        'lastMessage': 'See you soon! 💕',
        'time': 'Yesterday',
        'unreadCount': 0,
        'avatarColors': [Colors.purple.shade400, Colors.pink.shade600],
      },
      {
        'name': 'Rachel Green',
        'lastMessage': 'Had a great time today!',
        'time': 'Yesterday',
        'unreadCount': 0,
        'avatarColors': [Colors.indigo.shade400, Colors.blue.shade600],
      },
      {
        'name': 'Monica Garcia',
        'lastMessage': 'Let\'s plan something for weekend',
        'time': '2 days ago',
        'unreadCount': 0,
        'avatarColors': [Colors.teal.shade400, Colors.green.shade600],
      },
      {
        'name': 'Olivia Martinez',
        'lastMessage': 'Thanks for the lovely evening ✨',
        'time': '3 days ago',
        'unreadCount': 0,
        'avatarColors': [Colors.amber.shade400, Colors.orange.shade600],
      },
    ];
  }
}