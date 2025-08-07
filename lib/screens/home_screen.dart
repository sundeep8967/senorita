import 'package:flutter/material.dart';
import 'package:senorita/models/user_profile.dart';
import 'package:senorita/screens/profile_display_screen.dart';
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
  final FirebaseService _firebaseService = FirebaseService();
  UserProfile? _userProfile;
  List<UserProfile> _potentialMatches = [];
  int _currentMatchIndex = 0;
  bool _isLoading = true;
  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadData();
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final userProfileMap = await _firebaseService.getUserProfile();
    if (!mounted) return;

    if (userProfileMap == null) {
      setState(() => _isLoading = false);
      return;
    }

    final userId = _firebaseService.currentUserId!;
    final currentUserProfile = UserProfile.fromMap(userId, userProfileMap);

    List<UserProfile> matches = [];
    if (currentUserProfile.gender != null && currentUserProfile.gender!.isNotEmpty) {
      final matchDocs = await _firebaseService.getPotentialMatches(currentUserGender: currentUserProfile.gender!);
      matches = matchDocs.map((doc) => UserProfile.fromFirestore(doc)).toList();
    }

    setState(() {
      _userProfile = currentUserProfile;
      _potentialMatches = matches;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator()));
    }

    final homeContent = _potentialMatches.isEmpty ? _buildNoMatchesFound() : _buildHomeContent();

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
            child: (currentMatch.photos?.isNotEmpty ?? false)
                ? Image.network(currentMatch.photos![0], fit: BoxFit.cover, // Always show first photo
                    errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[800], child: const Center(child: Icon(Icons.broken_image, color: Colors.white, size: 100))),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
                      ));
                    },
                  )
                : Container(color: Colors.grey[800], child: const Center(child: Icon(Icons.person, color: Colors.white, size: 100))),
          ),
          Positioned.fill(child: Container(decoration: BoxDecoration(gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.transparent, Colors.black.withOpacity(0.8)],
            stops: const [0.0, 0.6, 1.0],
          )))),

          Positioned(
            bottom: 100, left: 24, right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((currentMatch.profession ?? '').isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                    ),
                    child: Text(currentMatch.profession!, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.w500)),
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

          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(child: SvgPicture.asset('assets/custom_icon.svg', width: 28, height: 28, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn))),
                    GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatScreen())), child: Icon(Icons.forum, color: Colors.white.withOpacity(0.6), size: 24)),
                    GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen())), child: Icon(Icons.notifications, color: Colors.white.withOpacity(0.6), size: 24)),
                    GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChooseCafeScreen())), child: _buildActionButton(Icons.whatshot)),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileDisplayScreen(
                        name: _userProfile?.fullName ?? '', age: _userProfile?.age ?? 0,
                        profession: _userProfile?.profession ?? '', bio: _userProfile?.bio ?? '',
                        location: _userProfile?.location ?? '', images: null,
                      ))),
                      child: SvgPicture.asset('assets/person_icon.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                    ),
                  ],
                ),
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