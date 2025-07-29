import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/themes/premium_theme.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/widgets/premium_button.dart';
import '../widgets/discovery_card.dart';
import '../widgets/action_buttons.dart';

class MainDiscoveryScreen extends StatefulWidget {
  const MainDiscoveryScreen({super.key});

  @override
  State<MainDiscoveryScreen> createState() => _MainDiscoveryScreenState();
}

class _MainDiscoveryScreenState extends State<MainDiscoveryScreen>
    with TickerProviderStateMixin {
  late AnimationController _cardController;
  late AnimationController _buttonController;
  int currentIndex = 0;

  final List<Map<String, dynamic>> profiles = [
    {
      'name': 'Emma',
      'age': 25,
      'bio': 'Love traveling and exploring new places. Coffee enthusiast ☕',
      'interests': ['Travel', 'Coffee', 'Photography'],
      'image': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'distance': 2.5,
      'isOnline': true,
    },
    {
      'name': 'Sophia',
      'age': 28,
      'bio': 'Yoga instructor and nature lover. Let\'s find peace together 🧘‍♀️',
      'interests': ['Yoga', 'Nature', 'Meditation'],
      'image': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'distance': 1.8,
      'isOnline': false,
    },
    {
      'name': 'Isabella',
      'age': 24,
      'bio': 'Foodie and adventure seeker. Life\'s too short for boring dates! 🍕',
      'interests': ['Food', 'Adventure', 'Travel'],
      'image': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'distance': 3.2,
      'isOnline': true,
    },
    {
      'name': 'Mia',
      'age': 26,
      'bio': 'Artist by day, dancer by night. Let\'s create something beautiful together 🎨',
      'interests': ['Art', 'Dancing', 'Music'],
      'image': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'distance': 4.1,
      'isOnline': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _cardController.forward();
    _buttonController.forward();
  }

  @override
  void dispose() {
    _cardController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  void _onSwipe(bool isLike) {
    if (isLike) {
      // For boys - show payment dialog before proceeding
      _showPaymentDialog();
    } else {
      // Regular pass - no payment required
      _processSwipe(false);
    }
  }

  void _processSwipe(bool isLike) {
    _cardController.reverse().then((_) {
      setState(() {
        if (currentIndex < profiles.length - 1) {
          currentIndex++;
        } else {
          currentIndex = 0; // Reset to first profile
        }
      });
      _cardController.forward();
    });

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isLike ? '💕 Liked!' : '👋 Passed'),
        duration: const Duration(milliseconds: 800),
        backgroundColor: isLike ? PremiumTheme.success : PremiumTheme.textSecondary,
      ),
    );
  }

  void _showPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('💕 Ready to Meet?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Choose your meetup package with ${profiles[currentIndex]['name']}:'),
            const SizedBox(height: 16),
            _buildPackageOption('Coffee Date', '₹500', 'Cafe meetup with beverages'),
            const SizedBox(height: 8),
            _buildPackageOption('Dinner Date', '₹1000', 'Restaurant with full meal'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageOption(String title, String price, String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: PremiumTheme.primaryPink),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(price, style: const TextStyle(color: PremiumTheme.primaryPink, fontWeight: FontWeight.bold)),
            ],
          ),
          Text(description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context, 
                  '/payment',
                  arguments: {
                    'profile': profiles[currentIndex],
                    'package': title,
                    'price': price,
                  },
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: PremiumTheme.primaryPink),
              child: Text('Pay $price & Request Meetup'),
            ),
          ),
        ],
      ),
    );
  }

  void _viewProfile() {
    Navigator.pushNamed(
      context,
      AppRouter.profileDetail,
      arguments: {'profile': profiles[currentIndex]},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: PremiumTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Discovery Cards
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    children: [
                      // Main Card
                      Expanded(
                        child: AnimatedBuilder(
                          animation: _cardController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _cardController.value,
                              child: Opacity(
                                opacity: _cardController.value,
                                child: DiscoveryCard(
                                  profile: profiles[currentIndex],
                                  onTap: _viewProfile,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      SizedBox(height: 20.h),
                      
                      // Action Buttons
                      AnimatedBuilder(
                        animation: _buttonController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _buttonController.value,
                            child: ActionButtons(
                              onPass: () => _onSwipe(false),
                              onLike: () => _onSwipe(true),
                              onSuperLike: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('⭐ Super Liked!'),
                                    backgroundColor: PremiumTheme.accentOrange,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                      
                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Discover',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: PremiumTheme.textPrimary,
                ),
              ),
              Text(
                'Los Angeles, CA',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: PremiumTheme.textSecondary,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _buildHeaderButton(
                icon: Icons.tune,
                onPressed: () {
                  // Show filters
                },
              ),
              SizedBox(width: 12.w),
              _buildHeaderButton(
                icon: Icons.notifications_outlined,
                onPressed: () {
                  // Show notifications
                },
                hasNotification: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool hasNotification = false,
  }) {
    return Container(
      width: 44.w,
      height: 44.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(22.r),
              onTap: onPressed,
              child: Center(
                child: Icon(
                  icon,
                  color: PremiumTheme.textPrimary,
                  size: 20.sp,
                ),
              ),
            ),
          ),
          if (hasNotification)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 8.w,
                height: 8.h,
                decoration: const BoxDecoration(
                  color: PremiumTheme.error,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 90.h,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.explore, 'Discover', true),
            _buildNavItem(Icons.chat_bubble_outline, 'Chats', false, onTap: () {
              Navigator.pushNamed(context, AppRouter.chatList);
            }),
            _buildNavItem(Icons.favorite_outline, 'Likes', false),
            _buildNavItem(Icons.person_outline, 'Profile', false, onTap: () {
              Navigator.pushNamed(context, AppRouter.userProfile);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? PremiumTheme.primaryPink : PremiumTheme.textSecondary,
            size: 24.sp,
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: isActive ? PremiumTheme.primaryPink : PremiumTheme.textSecondary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}