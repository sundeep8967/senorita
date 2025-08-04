import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        children: const [
          NotificationTile(
            title: 'New Match!',
            message: 'You have a new match with Sophia.',
            time: '10m ago',
            icon: Icons.favorite,
            iconColor: Colors.red,
          ),
          NotificationTile(
            title: 'New Message',
            message: 'Isabella sent you a message.',
            time: '1h ago',
            icon: Icons.message,
            iconColor: Color(0xFF007AFF),
          ),
          NotificationTile(
            title: 'Profile View',
            message: 'Someone viewed your profile.',
            time: '3h ago',
            icon: Icons.person,
            iconColor: Colors.white,
          ),
        ],
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color iconColor;

  const NotificationTile({
    Key? key,
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconColor.withOpacity(0.2),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        message,
        style: TextStyle(color: Colors.white.withOpacity(0.7)),
      ),
      trailing: Text(
        time,
        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
      ),
    );
  }
}
