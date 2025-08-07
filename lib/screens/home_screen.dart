import 'package:flutter/material.dart';
import 'package:senorita/models/user_profile.dart'; // Import UserProfile
import 'package:senorita/screens/profile_display_screen.dart';
import 'package:senorita/screens/verification_screen.dart';
import 'package:senorita/services/firebase_service.dart';

import 'package:senorita/screens/chat_screen.dart';
import 'package:senorita/screens/notification_screen.dart';
import 'package:senorita/screens/choose_cafe_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'dart:ui';

class HomeScreen extends StatefulWidget {
  final bool isLocked;

  const HomeScreen({Key? key, this.isLocked = false}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentImageIndex = 0;
  Timer? _imageTimer;
  final FirebaseService _firebaseService = FirebaseService();
  UserProfile? _userProfile; // Changed from Map to UserProfile
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final userProfileMap = await _firebaseService.getUserProfile();
    if (mounted) {
      if (userProfileMap != null) {
        final userId = _firebaseService.currentUserId!;
        setState(() {
          _userProfile = UserProfile.fromMap(userId, userProfileMap);
          _isLoading = false;
        });
        if (_userProfile?.photos != null && _userProfile!.photos!.isNotEmpty) {
          _startImageSlideshow();
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _startImageSlideshow() {
    if (_userProfile?.photos == null || _userProfile!.photos!.length <= 1) return;
    _imageTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % _userProfile!.photos!.length;
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
    if (_userProfile?.photos == null || _userProfile!.photos!.isEmpty) return;
    setState(() {
      if (side == 'left' && _currentImageIndex > 0) {
        _currentImageIndex--;
      } else if (side == 'right' && _currentImageIndex < _userProfile!.photos!.length - 1) {
        _currentImageIndex++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final homeContent = _buildHomeContent();

    if (widget.isLocked) {
      return Stack(
        children: [
          homeContent,
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock, color: Colors.white, size: 100),
                    const SizedBox(height: 20),
                    const Text('Profile Incomplete', style: TextStyle(color: Colors.white, fontSize: 24)),
                    const SizedBox(height: 10),
                    const Text('Please complete your profile to unlock.', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 30),
                    if (_userProfile != null && _userProfile!.missingSteps.isNotEmpty) ...[
                      const Text(
                        'Here\'s what\'s missing:',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        alignment: WrapAlignment.center,
                        children: _userProfile!.missingSteps
                            .map((step) => Chip(
                                  label: Text(step),
                                  backgroundColor: Colors.white.withOpacity(0.2),
                                  labelStyle: const TextStyle(color: Colors.white),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 30),
                    ],
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileDisplayScreen(
                              name: _userProfile?.fullName ?? '',
                              age: _userProfile?.age ?? 0,
                              profession: _userProfile?.profession ?? '',
                              bio: _userProfile?.bio ?? '',
                              location: _userProfile?.location ?? '',
                              images: null,
                            ),
                          ),
                        );
                      },
                      child: const Text('Complete Profile'),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return homeContent;
  }

  Widget _buildHomeContent() {
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
                  child: (_userProfile?.photos?.isNotEmpty ?? false)
                      ? Image.network(
                          _userProfile!.photos![_currentImageIndex],
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Colors.grey[800],
                          child: const Center(
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 100,
                            ),
                          ),
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
                _userProfile?.photos?.length ?? 0,
                (index) => Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: index < (_userProfile?.photos?.length ?? 1) - 1 ? 8 : 0),
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
                      _userProfile?.location ?? 'N/A',
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
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        opaque: false,
                        pageBuilder: (context, _, __) => const ChooseCafeScreen(),
                      ),
                    );
                  },
                  child: _buildActionButton(Icons.whatshot),
                ),
                const SizedBox(height: 16),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
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
                if ((_userProfile?.profession ?? '').isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _userProfile!.profession!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                // Name and Age
                Row(
                  children: [
                    Text(
                      '${_userProfile?.fullName ?? 'User'}, ${_userProfile?.age ?? 'N/A'}',
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
                if ((_userProfile?.bio ?? '').isNotEmpty)
                  Text(
                    _userProfile!.bio!,
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
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ChatScreen()),
                            );
                          },
                          child: Stack(
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
                        ),

                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const NotificationScreen()),
                            );
                          },
                          child: Icon(
                            Icons.notifications,
                            color: Colors.white.withOpacity(0.6),
                            size: 24,
                          ),
                        ),

                        SvgPicture.asset(
                          'assets/notch_icon.svg',
                          width: 24,
                          height: 24,
                          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                        ),

                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfileDisplayScreen(
                                  name: _userProfile?.fullName ?? '',
                                  age: _userProfile?.age ?? 0,
                                  profession: _userProfile?.profession ?? '',
                                  bio: _userProfile?.bio ?? '',
                                  location: _userProfile?.location ?? '',
                                  images: null,
                                ),
                              ),
                            );
                          },
                          child: SvgPicture.asset(
                            'assets/person_icon.svg',
                            width: 24,
                            height: 24,
                            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                          ),
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
        color: Colors.black.withOpacity(0.5),
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