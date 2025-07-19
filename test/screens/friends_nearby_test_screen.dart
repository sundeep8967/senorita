import 'package:flutter/material.dart';

void main() {
  runApp(FriendsNearbyApp());
}

class FriendsNearbyApp extends StatelessWidget {
  const FriendsNearbyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FriendsNearbyScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FriendsNearbyScreen extends StatelessWidget {
  const FriendsNearbyScreen({super.key});

  final List<String> profileImages = const [
    'https://i.pravatar.cc/100?img=1',
    'https://i.pravatar.cc/100?img=2',
    'https://i.pravatar.cc/100?img=3',
    'https://i.pravatar.cc/100?img=4',
    'https://i.pravatar.cc/100?img=5',
    'https://i.pravatar.cc/100?img=6',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFDEE9), Color(0xFFB5FFFC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Find close friends\nnear your location",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "12 people near you",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      for (int i = 0; i < profileImages.length; i++)
                        Positioned(
                          left: (i - 2) * 50.0,
                          child: CircleAvatar(
                            radius: i == 2 ? 45 : 30,
                            backgroundImage: NetworkImage(profileImages[i]),
                          ),
                        ),
                    ],
                  ),
                ),
                const Spacer(),
                Center(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: const Text("Detail profile"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}