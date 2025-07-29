import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/themes/app_theme.dart';
import 'core/di/injection_container.dart' as di;
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/authentication/presentation/pages/login/login_page.dart';
import 'features/authentication/presentation/pages/login/otp_verification_page.dart';
import 'features/profile/presentation/pages/profile_setup/profile_setup_page.dart';
import 'features/discovery/presentation/pages/glassmorphism_discovery_screen.dart';
import 'features/discovery/presentation/pages/swipe_discovery_screen.dart';
import 'features/onboarding/presentation/pages/gender_selection_page.dart';
import 'features/chat/presentation/pages/chat_screen.dart';
import 'features/payment/presentation/pages/date_booking_screen.dart';
import 'features/payment/presentation/pages/payment_screen.dart';
import 'features/onboarding/presentation/pages/male_profile_setup_page.dart';
import 'features/onboarding/presentation/pages/female_profile_setup_page.dart';
import 'features/authentication/presentation/pages/login/phone_association_page.dart';
import 'features/maps/presentation/pages/map_screen.dart';
import 'features/profile/presentation/pages/detailed_profile_screen.dart';
// Test screens - creating simplified versions within main app

class SenoritaApp extends StatelessWidget {
  const SenoritaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone 13 Pro design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(
              create: (_) => di.sl<AuthBloc>()..add(CheckAuthStatusEvent()),
            ),
          ],
          child: MaterialApp(
            title: 'Senorita - Premium Dating',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.glassmorphismTheme,
            darkTheme: AppTheme.glassmorphismTheme,
            themeMode: ThemeMode.dark,
            home: const ScreenSelectorPage(),
            routes: {
              '/login': (context) => const LoginPage(),
              '/profile-setup': (context) => const ProfileSetupPage(
                phoneNumber: '',
              ),
            },
          ),
        );
      },
    );
  }
}

class ScreenSelectorPage extends StatelessWidget {
  const ScreenSelectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Senorita - Screen Selector'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category: Discovery & Matching
                  _buildCategoryHeader('🔍 Discovery & Matching'),
                  _buildCategoryGrid([
                    _buildScreenCard(
                      context,
                      'Glassmorphism Discovery',
                      Icons.explore,
                      () => Navigator.push(context, MaterialPageRoute(
                        builder: (context) => const GlassmorphismDiscoveryScreen(),
                      )),
                    ),
                    _buildScreenCard(
                      context,
                      'Swipe Discovery',
                      Icons.swipe,
                      () => Navigator.push(context, MaterialPageRoute(
                        builder: (context) => const SwipeDiscoveryScreen(),
                      )),
                    ),
                    _buildScreenCard(
                      context,
                      'Map View',
                      Icons.map,
                      () => Navigator.push(context, MaterialPageRoute(
                        builder: (context) => const MapScreen(),
                      )),
                    ),
                  ]),
                  
                  SizedBox(height: 24.h),
                  
                  // Category: Authentication
                  _buildCategoryHeader('🔐 Authentication'),
                  _buildCategoryGrid([
                    _buildScreenCard(
                      context,
                      'Login Page',
                      Icons.login,
                      () => Navigator.push(context, MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      )),
                    ),
                    _buildScreenCard(
                      context,
                      'OTP Verification',
                      Icons.sms,
                      () => Navigator.push(context, MaterialPageRoute(
                        builder: (context) => const OtpVerificationPage(phoneNumber: '+1234567890'),
                      )),
                    ),
                    _buildScreenCard(
                      context,
                      'Phone Association',
                      Icons.phone_android,
                      () => Navigator.push(context, MaterialPageRoute(
                        builder: (context) => const PhoneAssociationPage(
                          userName: 'Demo User',
                          email: 'demo@example.com',
                        ),
                      )),
                    ),
                  ]),
                  
                  SizedBox(height: 24.h),
                  
                  // Category: Profile Setup
                  _buildCategoryHeader('👤 Profile Setup'),
                  _buildCategoryGrid([
                    _buildScreenCard(
                      context,
                      'Gender Selection',
                      Icons.person,
                      () => Navigator.push(context, MaterialPageRoute(
                        builder: (context) => const GenderSelectionPage(phoneNumber: '+1234567890'),
                      )),
                    ),
                    _buildScreenCard(
                      context,
                      'Profile Setup',
                      Icons.settings,
                      () => Navigator.push(context, MaterialPageRoute(
                        builder: (context) => const ProfileSetupPage(phoneNumber: '+1234567890'),
                      )),
                    ),
                    _buildScreenCard(
                      context,
                      'Detailed Profile',
                      Icons.account_box,
                      () => Navigator.push(context, MaterialPageRoute(
                        builder: (context) => const DetailedProfileScreen(),
                      )),
                    ),
                    _buildScreenCard(
                      context,
                      'Male Profile Setup',
                      Icons.man,
                      () => Navigator.push(context, MaterialPageRoute(
                        builder: (context) => const MaleProfileSetupPage(phoneNumber: '+1234567890'),
                      )),
                    ),
                    _buildScreenCard(
                      context,
                      'Female Profile Setup',
                      Icons.woman,
                      () => Navigator.push(context, MaterialPageRoute(
                        builder: (context) => const FemaleProfileSetupPage(phoneNumber: '+1234567890'),
                      )),
                    ),
                  ]),
                  
                  SizedBox(height: 24.h),
                  
                  // Category: Communication & Dating
                  _buildCategoryHeader('💬 Communication & Dating'),
                  _buildCategoryGrid([
                    _buildScreenCard(
                      context,
                      'Chat Screen',
                      Icons.chat,
                      () => Navigator.push(context, MaterialPageRoute(
                        builder: (context) => const ChatScreen(
                          matchId: 'demo_match_123',
                          matchedUserName: 'Emma',
                          matchedUserPhoto: 'https://i.pravatar.cc/400?img=1',
                          isOnline: true,
                        ),
                      )),
                    ),
                    _buildScreenCard(
                      context,
                      'Date Booking',
                      Icons.calendar_today,
                      () => Navigator.push(context, MaterialPageRoute(
                        builder: (context) => const DateBookingScreen(
                          matchedUserId: 'demo_user_456',
                          matchedUserName: 'Sophia',
                          matchedUserPhoto: 'https://i.pravatar.cc/400?img=2',
                        ),
                      )),
                    ),
                    _buildScreenCard(
                      context,
                      'Payment Screen',
                      Icons.payment,
                      () => Navigator.push(context, MaterialPageRoute(
                        builder: (context) => const PaymentScreen(
                          matchId: 'demo_match_789',
                          matchedUserName: 'Isabella',
                          matchedUserPhoto: 'https://i.pravatar.cc/400?img=3',
                        ),
                      )),
                    ),
                  ]),
                  
                  SizedBox(height: 24.h),
                  
                  // Category: Test & Demo Screens
                  _buildCategoryHeader('🧪 Test & Demo Screens'),
                  _buildCategoryGrid([
                    _buildScreenCard(
                      context,
                      'Friends Nearby',
                      Icons.location_on,
                      () => Navigator.push(context, MaterialPageRoute(
                        builder: (context) => const FriendsNearbyDemoScreen(),
                      )),
                    ),
                    _buildScreenCard(
                      context,
                      'Match Screen',
                      Icons.favorite,
                      () => Navigator.push(context, MaterialPageRoute(
                        builder: (context) => const MatchDemoScreen(),
                      )),
                    ),
                    _buildScreenCard(
                      context,
                      'SwingLove Home',
                      Icons.home,
                      () => Navigator.push(context, MaterialPageRoute(
                        builder: (context) => const SwingLoveDemoScreen(),
                      )),
                    ),
                    _buildScreenCard(
                      context,
                      'Yura Profile',
                      Icons.account_circle,
                      () => Navigator.push(context, MaterialPageRoute(
                        builder: (context) => const YuraProfileDemoScreen(),
                      )),
                    ),
                    _buildScreenCard(
                      context,
                      'Profile Story',
                      Icons.auto_stories,
                      () => Navigator.push(context, MaterialPageRoute(
                        builder: (context) => const ProfileStoryDemoScreen(),
                      )),
                    ),
                    _buildScreenCard(
                      context,
                      'Kate Profile',
                      Icons.person_4,
                      () => Navigator.push(context, MaterialPageRoute(
                        builder: (context) => const KateProfileDemoScreen(),
                      )),
                    ),
                  ]),
                  
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(List<Widget> children) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.85,
      children: children,
    );
  }

  Widget _buildScreenCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.1),
              Colors.white.withValues(alpha: 0.05),
            ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

}

// Demo Screen Implementations
class FriendsNearbyDemoScreen extends StatelessWidget {
  const FriendsNearbyDemoScreen({super.key});

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
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                ),
                const Text(
                  "Find close friends\nnear your location",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text("12 people near you", style: TextStyle(fontSize: 16)),
                const SizedBox(height: 40),
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      for (int i = 0; i < 6; i++)
                        Positioned(
                          left: (i - 2) * 50.0,
                          child: CircleAvatar(
                            radius: i == 2 ? 45 : 30,
                            backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=${i + 1}'),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text("Detail profile", style: TextStyle(color: Colors.white)),
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

class MatchDemoScreen extends StatelessWidget {
  const MatchDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  color: Colors.pink.withValues(alpha: 0.3),
                  child: const Center(
                    child: Icon(Icons.person, size: 100, color: Colors.white),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.blue.withValues(alpha: 0.3),
                  child: const Center(
                    child: Icon(Icons.person, size: 100, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const CircleAvatar(
                backgroundColor: Colors.black54,
                child: Icon(Icons.close, color: Colors.white),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'You matched',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Let's get to know\n each other better!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    icon: const Icon(Icons.message),
                    label: const Text('MESSAGE'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SwingLoveDemoScreen extends StatelessWidget {
  const SwingLoveDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBE9E7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Swinglove', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Your have ", style: TextStyle(fontSize: 24)),
            const Text.rich(
              TextSpan(
                text: '4 ',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(text: 'updated friends', style: TextStyle(fontWeight: FontWeight.normal)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Today, 09 Jul 2024'),
            ),
            const SizedBox(height: 20),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('My Friends', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Filter'),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=${index + 1}'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class YuraProfileDemoScreen extends StatelessWidget {
  const YuraProfileDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDE7E7),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFDE7E7), Color(0xFFFAD4EC), Color(0xFFE4C1F9)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, size: 28),
                  ),
                  const Icon(Icons.more_vert, size: 28),
                ],
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 120,
                      backgroundImage: NetworkImage('https://i.pravatar.cc/400?img=1'),
                    ),
                    const SizedBox(height: 16),
                    CircleAvatar(
                      radius: 36,
                      backgroundImage: NetworkImage('https://i.pravatar.cc/200?img=2'),
                    ),
                    const SizedBox(height: 12),
                    const Text('Yura Serena', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    const Wrap(
                      spacing: 10,
                      children: [
                        Chip(label: Text('UI Designer')),
                        Chip(label: Text('Lovely')),
                        Chip(label: Text('Music')),
                        Chip(label: Text('Yoga')),
                        Chip(label: Text('Vegetarian')),
                      ],
                    ),
                    const Spacer(),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CircleAvatar(radius: 28, backgroundColor: Colors.white, child: Icon(Icons.close)),
                        CircleAvatar(radius: 28, backgroundColor: Colors.white, child: Icon(Icons.chat_bubble_outline)),
                        CircleAvatar(radius: 28, backgroundColor: Colors.white, child: Icon(Icons.favorite, color: Colors.red)),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileStoryDemoScreen extends StatelessWidget {
  const ProfileStoryDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1544005313-94ddf0286df2'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage('https://images.unsplash.com/photo-1494790108755-2616b612b786'),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Elizabeth 21', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text('Cigarettes After Sex – "Sunsetz"', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'IT\'S YOU THAT I ADORE,\nAS WE DRIFT INTO THE NIGHT',
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, height: 1.4),
                textAlign: TextAlign.left,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class KateProfileDemoScreen extends StatelessWidget {
  const KateProfileDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1544005313-94ddf0286df2'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withValues(alpha: 0.3)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  ),
                  const Icon(Icons.more_vert, color: Colors.white, size: 28),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Kate 30",
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Wrap(
                  spacing: 8,
                  children: [
                    Chip(label: Text('Outdoor'), backgroundColor: Colors.white24),
                    Chip(label: Text('Design'), backgroundColor: Colors.white24),
                    Chip(label: Text('Diving'), backgroundColor: Colors.white24),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  "Hey there! My name is Kate and I'm a designer. I love exploring new places, trying out new diving spots, and spending time outdoors.",
                  style: TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
                ),
              ],
            ),
          ),
          const Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(radius: 28, backgroundColor: Colors.white24, child: Icon(Icons.close, color: Colors.white)),
                CircleAvatar(radius: 32, backgroundColor: Colors.white, child: Icon(Icons.local_fire_department, color: Colors.black)),
                CircleAvatar(radius: 28, backgroundColor: Colors.white24, child: Icon(Icons.star, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}