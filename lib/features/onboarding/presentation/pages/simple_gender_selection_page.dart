import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/themes/premium_theme.dart';
import '../../../../core/navigation/app_router.dart';

class GenderSelectionPage extends StatefulWidget {
  final String phoneNumber;
  final String? email;

  const GenderSelectionPage({
    super.key,
    required this.phoneNumber,
    this.email,
  });

  @override
  State<GenderSelectionPage> createState() => _GenderSelectionPageState();
}

class _GenderSelectionPageState extends State<GenderSelectionPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _controller.forward();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
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
          gradient: PremiumTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40.h),
                
                // Back button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 44.w,
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: PremiumTheme.textPrimary,
                      size: 20.sp,
                    ),
                  ),
                ),
                
                SizedBox(height: 40.h),
                
                // Title
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'I am a',
                          style: TextStyle(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.bold,
                            color: PremiumTheme.textPrimary,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Select your gender to personalize your experience',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: PremiumTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 60.h),
                
                // Gender options
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          _buildGenderOption(
                            gender: 'female',
                            title: 'Woman',
                            subtitle: 'I\'m looking for meaningful connections',
                            icon: Icons.female,
                            gradient: const LinearGradient(
                              colors: [PremiumTheme.primaryPink, Color(0xFFFF8E9B)],
                            ),
                          ),
                          
                          SizedBox(height: 20.h),
                          
                          _buildGenderOption(
                            gender: 'male',
                            title: 'Man',
                            subtitle: 'I\'m here to meet amazing people',
                            icon: Icons.male,
                            gradient: const LinearGradient(
                              colors: [PremiumTheme.primaryPurple, Color(0xFF764BA2)],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Continue button
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: double.infinity,
                      height: 56.h,
                      margin: EdgeInsets.only(bottom: 40.h),
                      child: ElevatedButton(
                        onPressed: _selectedGender != null ? _onContinue : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedGender != null 
                            ? PremiumTheme.primaryPink 
                            : PremiumTheme.textSecondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderOption({
    required String gender,
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
  }) {
    final isSelected = _selectedGender == gender;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = gender;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          gradient: isSelected ? gradient : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected 
              ? Colors.transparent 
              : PremiumTheme.border,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60.w,
              height: 60.h,
              decoration: BoxDecoration(
                color: isSelected 
                  ? Colors.white.withValues(alpha: 0.2)
                  : PremiumTheme.primaryPink.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : PremiumTheme.primaryPink,
                size: 30.sp,
              ),
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : PremiumTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isSelected 
                        ? Colors.white.withValues(alpha: 0.8)
                        : PremiumTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 24.sp,
              ),
          ],
        ),
      ),
    );
  }

  void _onContinue() {
    Navigator.pushNamed(
      context,
      AppRouter.profileSetup,
      arguments: {
        'phoneNumber': widget.phoneNumber,
        'email': widget.email,
        'gender': _selectedGender,
      },
    );
  }
}