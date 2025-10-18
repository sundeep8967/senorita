import 'package:flutter/material.dart';
import 'package:senorita/models/user_profile.dart';
import 'package:senorita/screens/profile_display_screen.dart';
import 'package:senorita/services/firebase_service.dart';
import 'package:senorita/services/supabase_service.dart';
import 'package:senorita/screens/chat_screen.dart';
import 'package:senorita/screens/chat_list_screen.dart';
import 'package:senorita/screens/timer_screen.dart';
import 'package:senorita/screens/notification_screen.dart';
import 'package:senorita/screens/meetups_screen.dart';
import 'package:senorita/screens/choose_cafe_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:senorita/services/app_notification_service.dart';
import 'dart:async';
import 'dart:ui';

class HomeScreen extends StatefulWidget {
  final bool isLocked;
  const HomeScreen({Key? key, this.isLocked = false}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final SupabaseService _supabaseService = SupabaseService.instance;
  final AppNotificationService _appNotificationService = AppNotificationService();
  UserProfile? _userProfile;
  List<UserProfile> _potentialMatches = [];
  int _currentMatchIndex = 0;
  bool _isLoading = true;
  PageController? _pageController;
  
  // Bottom navigation
  int _currentNavIndex = 0;
  
  // Cache for user images fetched from Supabase
  Map<String, List<String>> _userImagesCache = {};
  
  // Image slideshow variables
  int _currentImageIndex = 0;
  Timer? _imageTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadData();
    _startImageSlideshow();
  }

  void _startImageSlideshow() {
    _imageTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && _potentialMatches.isNotEmpty) {
        final currentMatch = _potentialMatches[_currentMatchIndex];
        final images = _userImagesCache[currentMatch.userId] ?? currentMatch.photos ?? [];
        if (images.isNotEmpty) {
          setState(() {
            _currentImageIndex = (_currentImageIndex + 1) % images.length;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController?.dispose();
    _imageTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    final userProfileMap = await _firebaseService.getUserProfile();
    if (!mounted) return;

    if (userProfileMap == null) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      return;
    }

    final userId = _firebaseService.currentUserId!;
    final currentUserProfile = UserProfile.fromMap(userId, userProfileMap);

    List<UserProfile> matches = [];
    if (currentUserProfile.gender != null && currentUserProfile.gender!.isNotEmpty) {
      final matchDocs = await _firebaseService.getPotentialMatches(currentUserGender: currentUserProfile.gender!);
      matches = matchDocs.map((doc) => UserProfile.fromFirestore(doc)).toList();
      
      // Fetch fresh images from Supabase for each match
      for (final match in matches) {
        await _fetchUserImages(match.userId);
      }
    }

    // Check mounted before calling setState after async operations
    if (!mounted) return;
    
    setState(() {
      _userProfile = currentUserProfile;
      _potentialMatches = matches;
      _isLoading = false;
    });
  }

  Future<void> _fetchUserImages(String userId) async {
    try {
      print('📸 Fetching fresh images from Supabase for user: $userId');
      final userImages = await _supabaseService.getUserImages(userId);
      final personalImages = userImages['personal'] ?? [];
      
      if (personalImages.isNotEmpty) {
        _userImagesCache[userId] = personalImages;
        print('✅ Cached ${personalImages.length} images for user: $userId');
      } else {
        print('ℹ️ No images found for user: $userId');
      }
    } catch (e) {
      print('❌ Error fetching images for user $userId: $e');
    }
  }

  String? _getUserImage(String userId) {
    final images = _userImagesCache[userId];
    return images?.isNotEmpty == true ? images!.first : null;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator()));
    }

    final homeContent = _buildMainContent();

    if (widget.isLocked) {
      return Stack(
        children: [
          homeContent,
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black.withOpacity(0.5)),
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
                      const Text('Here\'s what\'s missing:', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      const SizedBox(height: 15),
                      Wrap(
                        spacing: 8.0, runSpacing: 8.0, alignment: WrapAlignment.center,
                        children: _userProfile!.missingSteps.map((step) => Chip(
                          label: Text(step),
                          backgroundColor: Colors.white.withOpacity(0.2),
                          labelStyle: const TextStyle(color: Colors.white),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        )).toList(),
                      ),
                      const SizedBox(height: 30),
                    ],
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                      ),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileDisplayScreen(
                        name: _userProfile?.fullName ?? '', age: _userProfile?.age ?? 0,
                        profession: _userProfile?.profession ?? '', bio: _userProfile?.bio ?? '',
                        location: _userProfile?.location ?? '', images: null,
                      ))),
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

  Widget _buildMainContent() {
    Widget content;
    
    switch (_currentNavIndex) {
      case 0:
        return _potentialMatches.isEmpty ? _buildNoMatchesFound() : _buildHomeContent();
      case 1:
        content = const ChatListScreen();
        break;
      case 2:
        content = const MeetupsScreen();
        break;
      case 3:
        content = const TimerScreen();
        break;
      case 4:
        content = ProfileDisplayScreen(
          name: _userProfile?.fullName ?? '',
          age: _userProfile?.age ?? 0,
          profession: _userProfile?.profession ?? '',
          bio: _userProfile?.bio ?? '',
          location: _userProfile?.location ?? '',
          images: null,
        );
        break;
      default:
        return _potentialMatches.isEmpty ? _buildNoMatchesFound() : _buildHomeContent();
    }
    
    // For non-home tabs, wrap content with scaffold and bottom nav
    return Scaffold(
      backgroundColor: Colors.black,
      body: content,
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildNoMatchesFound() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sentiment_dissatisfied, color: Colors.white54, size: 80),
            const SizedBox(height: 20),
            const Text('No Matches Found', style: TextStyle(color: Colors.white, fontSize: 22)),
            const SizedBox(height: 10),
            Text('Try adjusting your preferences.', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16)),
          ],
        ),
      )
    );
  }

  Widget _buildHomeContent() {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: _potentialMatches.length,
      onPageChanged: (index) {
        setState(() {
          _currentMatchIndex = index;
          _currentImageIndex = 0; // Reset image index when switching users
        });
      },
      itemBuilder: (context, index) {
        final currentMatch = _potentialMatches[index];
        return _buildProfilePage(currentMatch);
      },
    );
  }

  Widget _buildProfilePage(UserProfile currentMatch) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: _buildUserImage(currentMatch),
          ),
          Positioned.fill(child: Container(decoration: BoxDecoration(gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.transparent, Colors.black.withOpacity(0.8)],
            stops: const [0.0, 0.6, 1.0],
          )))),

          // Image Progress Indicators
          Positioned(
            top: MediaQuery.of(context).padding.top + 5,
            left: 16,
            right: 16,
            child: Row(
              children: List.generate(
                (_userImagesCache[currentMatch.userId] ?? currentMatch.photos ?? []).length,
                (index) => Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: index < (_userImagesCache[currentMatch.userId] ?? currentMatch.photos ?? []).length - 1 ? 8 : 0),
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
                      currentMatch.location ?? 'Unknown Location',
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

          // Notification Bell Icon (Top Right)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: StreamBuilder<int>(
              stream: _appNotificationService.getUnreadCount(),
              builder: (context, snapshot) {
                final unreadCount = snapshot.data ?? 0;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotificationScreen()),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(
                              Icons.notifications_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                            if (unreadCount > 0)
                              Positioned(
                                top: -4,
                                right: -4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 18,
                                    minHeight: 18,
                                  ),
                                  child: Text(
                                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Positioned(
            bottom: 100, left: 24, right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((currentMatch.profession ?? '').isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            currentMatch.profession!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                Row(
                  children: [
                    Text('${currentMatch.fullName ?? 'User'}, ${currentMatch.age ?? 'N/A'}', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    Container(
                      width: 24, height: 24,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.verified, color: Colors.black, size: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if ((currentMatch.bio ?? '').isNotEmpty)
                  Text(currentMatch.bio!, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16, height: 1.5)),
              ],
            ),
          ),

          // Right Side Action Buttons (Fire & Timer)
          Positioned(
            right: 16,
            top: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              children: [
                // Fire button (Cafe selection)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    if (_potentialMatches.isNotEmpty) {
                      final currentMatch = _potentialMatches[_currentMatchIndex];
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          opaque: false,
                          pageBuilder: (context, _, __) => ChooseCafeScreen(currentMatch: currentMatch),
                        ),
                      );
                    }
                  },
                  child: _buildBlurButton(Icons.local_fire_department, Colors.white),
                ),
                const SizedBox(height: 16),
                
                // Decorative dot
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildBottomNavBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildUserImage(UserProfile currentMatch) {
    final images = _userImagesCache[currentMatch.userId] ?? currentMatch.photos ?? [];
    final imageUrl = images.isNotEmpty ? images[_currentImageIndex % images.length] : null;
    
    if (imageUrl != null) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('❌ Failed to load image: $imageUrl');
          return Container(
            color: Colors.grey[800],
            child: const Center(
              child: Icon(Icons.broken_image, color: Colors.white, size: 100),
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null 
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! 
                  : null,
              color: Colors.white,
            ),
          );
        },
      );
    } else {
      return Container(
        color: Colors.grey[800],
        child: const Center(
          child: Icon(Icons.person, color: Colors.white, size: 100),
        ),
      );
    }
  }

  Widget _buildActionButton(IconData icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildBlurButton(IconData icon, Color iconColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              child: Icon(
                icon,
                color: iconColor,
                size: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 12,
            top: 20,
            left: 20,
            right: 20,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                icon: 'assets/custom_icon.svg',
                isActive: _currentNavIndex == 0,
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _currentNavIndex = 0;
                  });
                },
              ),
              _buildNavItem(
                iconData: Icons.forum_outlined,
                isActive: _currentNavIndex == 1,
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _currentNavIndex = 1;
                  });
                },
              ),
              _buildNavItem(
                iconData: Icons.coffee_outlined,
                isActive: _currentNavIndex == 2,
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _currentNavIndex = 2;
                  });
                },
              ),
              _buildNavItem(
                icon: 'assets/notch_icon.svg',
                isActive: _currentNavIndex == 3,
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _currentNavIndex = 3;
                  });
                },
              ),
              _buildNavItem(
                icon: 'assets/person_icon.svg',
                isActive: _currentNavIndex == 4,
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _currentNavIndex = 4;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    String? icon,
    IconData? iconData,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive 
              ? Colors.white.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isActive 
              ? Border.all(color: Colors.white.withOpacity(0.2), width: 1)
              : null,
        ),
        child: AnimatedScale(
          scale: isActive ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: icon != null
              ? SvgPicture.asset(
                  icon,
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    isActive 
                        ? Colors.white
                        : Colors.white.withOpacity(0.6),
                    BlendMode.srcIn,
                  ),
                )
              : Icon(
                  iconData!,
                  color: isActive 
                      ? Colors.white
                      : Colors.white.withOpacity(0.6),
                  size: 24,
                ),
        ),
      ),
    );
  }
}