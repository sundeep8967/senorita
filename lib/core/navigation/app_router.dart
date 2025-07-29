import 'package:flutter/material.dart';
import '../../features/onboarding/presentation/pages/splash_screen.dart';
import '../../features/onboarding/presentation/pages/welcome_screen.dart';
import '../../features/authentication/presentation/pages/login/simple_login_page.dart';
import '../../features/onboarding/presentation/pages/simple_gender_selection_page.dart';
import '../../features/profile/presentation/pages/profile_setup/simple_profile_setup_page.dart';
import '../../features/discovery/presentation/pages/main_discovery_screen.dart';
import '../../features/discovery/presentation/pages/profile_detail_screen.dart';
import '../../features/chat/presentation/pages/chat_list_screen.dart';
import '../../features/chat/presentation/pages/chat_screen.dart';
import '../../features/profile/presentation/pages/user_profile_screen.dart';
import '../widgets/premium_page_transition.dart';

class AppRouter {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String genderSelection = '/gender-selection';
  static const String profileSetup = '/profile-setup';
  static const String discovery = '/discovery';
  static const String profileDetail = '/profile-detail';
  static const String chatList = '/chat-list';
  static const String chat = '/chat';
  static const String userProfile = '/user-profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return PremiumPageTransition(
          child: const SplashScreen(),
          settings: settings,
        );
      
      case welcome:
        return PremiumPageTransition(
          child: const WelcomeScreen(),
          settings: settings,
        );
      
      case login:
        return PremiumPageTransition(
          child: const LoginPage(),
          settings: settings,
        );
      
      case genderSelection:
        final args = settings.arguments as Map<String, dynamic>?;
        return PremiumPageTransition(
          child: GenderSelectionPage(
            phoneNumber: args?['phoneNumber'] ?? '',
            email: args?['email'],
          ),
          settings: settings,
        );
      
      case profileSetup:
        final args = settings.arguments as Map<String, dynamic>?;
        return PremiumPageTransition(
          child: ProfileSetupPage(
            phoneNumber: args?['phoneNumber'] ?? '',
            userName: args?['userName'],
            email: args?['email'],
          ),
          settings: settings,
        );
      
      case discovery:
        return PremiumPageTransition(
          child: const MainDiscoveryScreen(),
          settings: settings,
        );
      
      case profileDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return PremiumPageTransition(
          child: ProfileDetailScreen(
            profile: args?['profile'],
          ),
          settings: settings,
        );
      
      case chatList:
        return PremiumPageTransition(
          child: const ChatListScreen(),
          settings: settings,
        );
      
      case chat:
        final args = settings.arguments as Map<String, dynamic>?;
        return PremiumPageTransition(
          child: ChatScreen(
            matchId: args?['matchId'] ?? '',
            matchedUserName: args?['matchedUserName'] ?? '',
            matchedUserPhoto: args?['matchedUserPhoto'] ?? '',
            isOnline: args?['isOnline'] ?? false,
          ),
          settings: settings,
        );
      
      case userProfile:
        return PremiumPageTransition(
          child: const UserProfileScreen(),
          settings: settings,
        );
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}