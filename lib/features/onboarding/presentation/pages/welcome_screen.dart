import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';
import '../../../../core/themes/ios_glassmorphism_theme.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/widgets/glassmorphism_widgets.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _controller.forward();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: IOSGlassmorphismTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 40.h),
                  
                  // Hero Image
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: GlassContainer(
                      width: double.infinity,
                      height: 300.h,
                      borderRadius: 30,
                      blur: 20,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30.r),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
                              fit: BoxFit.cover,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.4),
                                  ],
                                ),
                              ),
                            ),
                            // Glass overlay
                            BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withValues(alpha: 0.1),
                                      Colors.white.withValues(alpha: 0.05),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 40.h),
                
                // Welcome Content
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          'Find Your Perfect\nMatch',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.2,
                            letterSpacing: -1.0,
                          ),
                        ),
                        
                        SizedBox(height: 16.h),
                        
                        Text(
                          'Connect with like-minded people and discover meaningful relationships in a premium dating experience.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.white.withValues(alpha: 0.8),
                            height: 1.5,
                            letterSpacing: -0.2,
                          ),
                        ),
                        
                        SizedBox(height: 40.h),
                        
                        // Get Started Button
                        GlassButton(
                          'Get Started',
                          onPressed: () {
                            Navigator.pushNamed(context, AppRouter.login);
                          },
                          isPrimary: true,
                          gradient: IOSGlassmorphismTheme.primaryGradient,
                          width: double.infinity,
                          fontSize: 18,
                        ),
                        
                        SizedBox(height: 16.h),
                        
                        // Terms and Privacy
                        Text(
                          'By continuing, you agree to our Terms of Service\nand Privacy Policy',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white.withValues(alpha: 0.6),
                            height: 1.4,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 40.h),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}