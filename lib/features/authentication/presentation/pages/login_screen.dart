
import 'package:flutter/cupertino.dart';
import 'package:senorita/features/authentication/presentation/pages/phone_verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0?q=80&w=2574&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Frosted Glass Effect
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          // Login UI
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                // App Title
                Text(
                  'senorita',
                  style: TextStyle(
                    fontSize: 48.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2.0,
                  ),
                ),
                const Spacer(),
                // Social Login Buttons
                _buildSocialLoginButton(
                  text: 'Continue with Google',
                  icon: CupertinoIcons.globe,
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (context) => const PhoneVerificationScreen()),
                    );
                  },
                ),
                
                const Spacer(flex: 3),
                // Terms and Conditions
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.w),
                  child: Text(
                    'By continuing, you agree to our Terms of Service and Privacy Policy.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12.sp,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLoginButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: CupertinoButton(
        onPressed: onPressed,
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30.r),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 10.w),
            Text(
              text,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
