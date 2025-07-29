import 'package:flutter/material.dart';

class DetailedProfileScreen extends StatelessWidget {
  const DetailedProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1503023345310-bd7c1de61c7d', // Replace with your image
              fit: BoxFit.cover,
            ),
          ),
          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  // Location Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.white, size: 18),
                        SizedBox(width: 6),
                        Text(
                          "Los Angeles, CA",
                          style: TextStyle(color: Colors.white),
                        ),
                        Icon(Icons.keyboard_arrow_down, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Right side action buttons
          Positioned(
            right: 16,
            top: MediaQuery.of(context).size.height * 0.35,
            child: Column(
              children: [
                _actionButton(Icons.favorite_border, () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Liked! 💕')),
                  );
                }),
                const SizedBox(height: 16),
                _actionButton(Icons.message_outlined, () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening chat... 💬')),
                  );
                }),
                const SizedBox(height: 16),
                _actionButton(Icons.more_vert, () {
                  _showMoreOptions(context);
                }),
              ],
            ),
          ),
          // Bottom user details
          const Positioned(
            left: 16,
            bottom: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Sophia Williams, 25",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Book lover, coffee enthusiast, and part-time traveler.\nLooking for someone to share deep conversations...",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _bottomNavBar(context),
    );
  }

  Widget _actionButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: 26,
        child: Icon(icon, color: Colors.black87),
      ),
    );
  }

  Widget _bottomNavBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.pink,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: (index) {
        switch (index) {
          case 0:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Home 🏠')),
            );
            break;
          case 1:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Messages 💬')),
            );
            break;
          case 2:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Likes ❤️')),
            );
            break;
          case 3:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile 👤')),
            );
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.message_outlined), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.favorite_outline), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
      ],
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            _optionTile(Icons.report, 'Report', Colors.red),
            _optionTile(Icons.block, 'Block', Colors.orange),
            _optionTile(Icons.share, 'Share Profile', Colors.blue),
            _optionTile(Icons.info_outline, 'View Full Profile', Colors.green),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _optionTile(IconData icon, String title, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      onTap: () {
        // Handle option tap
      },
    );
  }
}

// Standalone app for testing this screen
class DetailedProfileApp extends StatelessWidget {
  const DetailedProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DetailedProfileScreen(),
    );
  }
}