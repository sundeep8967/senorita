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
  String? _selectedGender;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectUserType(UserType userType) {
    setState(() {
      _selectedUserType = userType;
    });
  }

  void _continue() {
    if (_selectedUserType == null) {
      context.showErrorSnackBar('Please select your gender');
      return;
    }

    if (_selectedUserType == UserType.male) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MaleProfileSetupPage(
            phoneNumber: widget.phoneNumber,
            email: widget.email,
          ),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => FemaleProfileSetupPage(
            phoneNumber: widget.phoneNumber,
            email: widget.email,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE91E63),
              Color(0xFFAD1457),
              Color(0xFF9C27B0),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    SizedBox(height: 60.h),
                    _buildHeader(),
                    SizedBox(height: 60.h),
                    Expanded(
                      child: _buildGenderOptions(),
                    ),
                    _buildContinueButton(),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'I am a',
          style: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'This helps us create the perfect experience for you',
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.white.withValues(alpha: 0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildGenderOptions() {
    return Column(
      children: [
        _buildGenderCard(
          userType: UserType.male,
          title: 'Man',
          subtitle: 'Looking for amazing dates',
          icon: Icons.person,
          description: '• Pay for premium meetup experiences\n• Choose from coffee, dinner, or luxury dates\n• Get guaranteed meetups with matched women',
        ),
        SizedBox(height: 24.h),
        _buildGenderCard(
          userType: UserType.female,
          title: 'Woman',
          subtitle: 'Enjoy free premium dates',
          icon: Icons.person_outline,
          description: '• Enjoy free dining experiences\n• Safe and verified meetup environments\n• Free transportation and premium venues',
        ),
      ],
    );
  }

  Widget _buildGenderCard({
    required UserType userType,
    required String title,
    required String subtitle,
    required IconData icon,
    required String description,
  }) {
    final isSelected = _selectedUserType == userType;
    
    return GestureDetector(
      onTap: () => _selectUserType(userType),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.white 
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected 
                ? AppColors.primary 
                : Colors.white.withValues(alpha: 0.3),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 60.w,
                  height: 60.h,
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppColors.primary 
                        : Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 30.sp,
                    color: isSelected 
                        ? Colors.white 
                        : Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: isSelected 
                              ? AppColors.textPrimary 
                              : Colors.white,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isSelected 
                              ? AppColors.textSecondary 
                              : Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: 24.sp,
                  ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              description,
              style: TextStyle(
                fontSize: 13.sp,
                color: isSelected 
                    ? AppColors.textSecondary 
                    : Colors.white.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: _selectedUserType != null ? _continue : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
        child: Text(
          'Continue',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}