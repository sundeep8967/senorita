import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentImageIndex = 0;
  Timer? _imageTimer;
  
  final Map<String, dynamic> profileData = {
    'name': 'Sophia Williams',
    'age': 25,
    'distance': '3.5 Km Away',
    'location': 'Bangalore, KA',
    'profession': 'Software Engineer',
    'bio': 'Book lover, coffee enthusiast, and part-time traveler. Looking for someone to share deep conversations and...',
    'images': [
      'assets/girl1a.jpg',
      'assets/girl1b.jpg',
      'assets/girl1c.jpg',
    ]
  };

  @override
  void initState() {
    super.initState();
    _startImageSlideshow();
  }

  void _startImageSlideshow() {
    _imageTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % (profileData['images'] as List).length;
        });
      }
    });
  }

  @override
  void dispose() {
    _imageTimer?.cancel();
    super.dispose();
  }

  void _handleImageTap(String side) {
    setState(() {
      if (side == 'left' && _currentImageIndex > 0) {
        _currentImageIndex--;
      } else if (side == 'right' && _currentImageIndex < (profileData['images'] as List).length - 1) {
        _currentImageIndex++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Status Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
                left: 24,
                right: 24,
                bottom: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '9:41',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      // Signal bars
                      Row(
                        children: [
                          Container(width: 4, height: 12, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2))),
                          const SizedBox(width: 2),
                          Container(width: 4, height: 12, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2))),
                          const SizedBox(width: 2),
                          Container(width: 4, height: 12, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2))),
                          const SizedBox(width: 2),
                          Container(width: 4, height: 12, decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), borderRadius: BorderRadius.circular(2))),
                        ],
                      ),
                      const SizedBox(width: 8),
                      // WiFi icon
                      const Icon(Icons.wifi, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      // Battery
                      Container(
                        width: 24,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 4,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(2),
                                bottomRight: Radius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Main Image Container
          Positioned.fill(
            child: Stack(
              children: [
                // Profile Image
                Positioned.fill(
                  child: Image.asset(
                    profileData['images'][_currentImageIndex],
                    fit: BoxFit.cover,
                  ),
                ),

                // Tap zones for image navigation
                Positioned.fill(
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _handleImageTap('left'),
                          child: Container(color: Colors.transparent),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _handleImageTap('right'),
                          child: Container(color: Colors.transparent),
                        ),
                      ),
                    ],
                  ),
                ),

                // Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Image Progress Indicators
          Positioned(
            top: MediaQuery.of(context).padding.top + 5,
            left: 16,
            right: 16,
            child: Row(
              children: List.generate(
                (profileData['images'] as List).length,
                (index) => Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: index < (profileData['images'] as List).length - 1 ? 8 : 0),
                    decoration: BoxDecoration(
                      color: index == _currentImageIndex ? Colors.white : Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          ),

          

          // Location Badge
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      profileData['location'],
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.location_on,
                      color: Colors.black,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Right Side Action Buttons
          Positioned(
            right: 16,
            top: MediaQuery.of(context).size.height * 0.4,
            child: Column(
              children: [
                
                _buildActionButton(Icons.favorite_border),
                const SizedBox(height: 16),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 16),
                _buildActionButton(Icons.more_horiz),
                const SizedBox(height: 16),
                _buildActionButton(Icons.message),
              ],
            ),
          ),

          // Bottom Profile Info
          Positioned(
            bottom: 100,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profession
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    profileData['profession'],
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                
                
                // Name and Age
                Row(
                  children: [
                    Text(
                      '${profileData['name']}, ${profileData['age']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified,
                        color: Colors.black,
                        size: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Bio
                Text(
                  profileData['bio'],
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // Bottom Navigation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Home icon (active)
                        Container(
                          width: 48,
                          height: 32,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              'assets/custom_icon.svg',
                              width: 28,
                              height: 28,
                              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                            ),
                          ),
                        ),
                        
                        // Messages with notification
                        Stack(
                          children: [
                            Icon(
                              Icons.forum,
                              color: Colors.white.withOpacity(0.6),
                              size: 24,
                            ),
                            Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Text(
                                    '12',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        Icon(
                          Icons.notifications,
                          color: Colors.white.withOpacity(0.6),
                          size: 24,
                        ),
                        
                        SvgPicture.asset(
                          'assets/notch_icon.svg',
                          width: 24,
                          height: 24,
                          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                        ),
                        
                        SvgPicture.asset(
                          'assets/person_icon.svg',
                          width: 24,
                          height: 24,
                          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}