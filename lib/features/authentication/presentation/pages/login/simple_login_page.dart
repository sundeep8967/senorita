import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/themes/premium_theme.dart';
import '../../../../../core/navigation/app_router.dart';
import '../../../../../core/widgets/premium_button.dart';
import '../../../../../core/services/google_auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await _googleAuthService.signInWithGoogle();
      
      if (userCredential != null && mounted) {
        final user = userCredential.user;
        if (user != null) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome ${user.displayName ?? user.email}!'),
              backgroundColor: PremiumTheme.success,
            ),
          );

          // Navigate to gender selection with real user data
          Navigator.pushNamed(
            context,
            AppRouter.genderSelection,
            arguments: {
              'phoneNumber': user.phoneNumber ?? '',
              'email': user.email ?? '',
              'userName': user.displayName ?? '',
              'photoURL': user.photoURL ?? '',
            },
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign in failed: ${e.toString()}'),
            backgroundColor: PremiumTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: PremiumTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                SizedBox(height: 60.h),
                
                // Logo
                Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    gradient: PremiumTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Icon(
                    Icons.favorite,
                    size: 40.sp,
                    color: Colors.white,
                  ),
                ),
                
                SizedBox(height: 40.h),
                
                Text(
                  'Welcome to Senorita',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: PremiumTheme.textPrimary,
                  ),
                ),
                
                SizedBox(height: 8.h),
                
                Text(
                  'Find your perfect match',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: PremiumTheme.textSecondary,
                  ),
                ),
                
                const Spacer(),
                
                // Login Options
                PremiumButton(
                  text: 'Continue with Phone',
                  icon: Icons.phone,
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRouter.genderSelection,
                      arguments: {
                        'phoneNumber': '+1234567890',
                        'email': 'demo@senorita.com',
                      },
                    );
                  },
                ),
                
                SizedBox(height: 16.h),
                
                PremiumButton(
                  text: 'Continue with Google',
                  icon: Icons.g_mobiledata,
                  isOutlined: true,
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _signInWithGoogle,
                ),
                
                SizedBox(height: 40.h),
                
                Text(
                  'By continuing, you agree to our Terms of Service\nand Privacy Policy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: PremiumTheme.textSecondary,
                  ),
                ),
                
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}