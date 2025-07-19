import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';
import '../../../../core/themes/colors.dart';
import '../../../../core/widgets/glassmorphism_widgets.dart';

class GlassmorphismDiscoveryScreen extends StatefulWidget {
  const GlassmorphismDiscoveryScreen({super.key});

  @override
  State<GlassmorphismDiscoveryScreen> createState() => _GlassmorphismDiscoveryScreenState();
}

class _GlassmorphismDiscoveryScreenState extends State<GlassmorphismDiscoveryScreen>
    with TickerProviderStateMixin {
  late AnimationController _cardController;
  late AnimationController _buttonController;
  late Animation<double> _cardAnimation;
  late Animation<double> _buttonAnimation;

  final List<ProfileData> _profiles = [
    ProfileData(
      name: "Emma",
      age: 25,
      bio: "Love traveling and exploring new places. Coffee enthusiast ☕",
      interests: ["Travel", "Coffee", "Photography"],
      imageUrl: "https://i.pravatar.cc/400?img=1",
    ),
    ProfileData(
      name: "Sophia",
      age: 28,
      bio: "Yoga instructor and nature lover. Let's find peace together 🧘‍♀️",
      interests: ["Yoga", "Nature", "Meditation"],
      imageUrl: "https://i.pravatar.cc/400?img=2",
    ),
    ProfileData(
      name: "Isabella",
      age: 26,
      bio: "Artist and dreamer. Creating beautiful moments one day at a time 🎨",
      interests: ["Art", "Music", "Dancing"],
      imageUrl: "https://i.pravatar.cc/400?img=3",
    ),
  ];

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _cardAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeInOut),
    );
    _buttonAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _cardController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  void _swipeCard(bool isLike) {
    _cardController.forward().then((_) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _profiles.length;
      });
      _cardController.reset();
    });
    
    _buttonController.forward().then((_) {
      _buttonController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: "Discover",
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                SizedBox(height: 20.h),
                
                // Profile Cards Stack
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background cards
                      for (int i = 1; i < 3; i++)
                        if (_currentIndex + i < _profiles.length)
                          Transform.scale(
                            scale: 1.0 - (i * 0.05),
                            child: Transform.translate(
                              offset: Offset(0, i * 10.0),
                              child: _buildProfileCard(_profiles[_currentIndex + i], false),
                            ),
                          ),
                      
                      // Main card
                      AnimatedBuilder(
                        animation: _cardAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _cardAnimation.value,
                            child: Transform.rotate(
                              angle: _cardAnimation.value * 0.1,
                              child: Opacity(
                                opacity: _cardAnimation.value,
                                child: _buildProfileCard(_profiles[_currentIndex], true),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 30.h),
                
                // Action Buttons
                _buildActionButtons(),
                
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(ProfileData profile, bool isMainCard) {
    return GlassCard(
      width: double.infinity,
      height: 500.h,
      borderRadius: 25,
      child: Stack(
        children: [
          // Background Image
          ClipRRect(
            borderRadius: BorderRadius.circular(25.r),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(profile.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Profile Info
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25.r),
                bottomRight: Radius.circular(25.r),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      top: BorderSide(color: AppColors.border),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${profile.name}, ${profile.age}",
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        profile.bio,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: profile.interests.map((interest) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(15.r),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              interest,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Top Actions
          if (isMainCard)
            Positioned(
              top: 20.h,
              right: 20.w,
              child: GlassCard(
                padding: EdgeInsets.all(8.w),
                borderRadius: 15,
                child: Icon(
                  Icons.more_vert,
                  color: AppColors.textPrimary,
                  size: 20.sp,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Pass Button
        AnimatedBuilder(
          animation: _buttonAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _buttonAnimation.value,
              child: GlassFloatingActionButton(
                size: 60,
                onPressed: () => _swipeCard(false),
                child: Icon(
                  Icons.close,
                  color: AppColors.error,
                  size: 28.sp,
                ),
              ),
            );
          },
        ),
        
        // Super Like Button
        GlassFloatingActionButton(
          size: 50,
          onPressed: () {},
          child: Icon(
            Icons.star,
            color: AppColors.warning,
            size: 24.sp,
          ),
        ),
        
        // Like Button
        AnimatedBuilder(
          animation: _buttonAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _buttonAnimation.value,
              child: GlassFloatingActionButton(
                size: 60,
                onPressed: () => _swipeCard(true),
                child: Icon(
                  Icons.favorite,
                  color: AppColors.success,
                  size: 28.sp,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class ProfileData {
  final String name;
  final int age;
  final String bio;
  final List<String> interests;
  final String imageUrl;

  ProfileData({
    required this.name,
    required this.age,
    required this.bio,
    required this.interests,
    required this.imageUrl,
  });
}