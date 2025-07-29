import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/themes/premium_theme.dart';
import '../../../../../core/navigation/app_router.dart';
import '../../../../../core/widgets/premium_button.dart';

class ProfileSetupPage extends StatefulWidget {
  final String phoneNumber;
  final String? userName;
  final String? email;

  const ProfileSetupPage({
    super.key,
    required this.phoneNumber,
    this.userName,
    this.email,
  });

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  int _age = 25;
  final List<String> _selectedInterests = [];

  final List<String> _interests = [
    'Travel', 'Coffee', 'Photography', 'Music', 'Art', 'Yoga',
    'Food', 'Dancing', 'Reading', 'Movies', 'Sports', 'Nature',
    'Fashion', 'Technology', 'Cooking', 'Fitness', 'Gaming', 'Wine'
  ];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.userName ?? '';
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
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Row(
                  children: [
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
                    SizedBox(width: 16.w),
                    Text(
                      'Setup Profile',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: PremiumTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Photo
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 60.r,
                              backgroundColor: PremiumTheme.primaryPink.withValues(alpha: 0.1),
                              child: Icon(
                                Icons.person,
                                size: 60.sp,
                                color: PremiumTheme.primaryPink,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 36.w,
                                height: 36.h,
                                decoration: BoxDecoration(
                                  gradient: PremiumTheme.primaryGradient,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: PremiumTheme.primaryPink.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 18.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 40.h),
                      
                      // Name Field
                      Text(
                        'Name',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: PremiumTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'Enter your name',
                        ),
                      ),
                      
                      SizedBox(height: 24.h),
                      
                      // Age Slider
                      Text(
                        'Age: $_age',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: PremiumTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: PremiumTheme.primaryPink,
                          inactiveTrackColor: PremiumTheme.primaryPink.withValues(alpha: 0.2),
                          thumbColor: PremiumTheme.primaryPink,
                          overlayColor: PremiumTheme.primaryPink.withValues(alpha: 0.2),
                        ),
                        child: Slider(
                          value: _age.toDouble(),
                          min: 18,
                          max: 65,
                          divisions: 47,
                          onChanged: (value) {
                            setState(() {
                              _age = value.round();
                            });
                          },
                        ),
                      ),
                      
                      SizedBox(height: 24.h),
                      
                      // Bio Field
                      Text(
                        'Bio',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: PremiumTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: _bioController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Tell us about yourself...',
                        ),
                      ),
                      
                      SizedBox(height: 24.h),
                      
                      // Interests
                      Text(
                        'Interests',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: PremiumTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: _interests.map((interest) {
                          final isSelected = _selectedInterests.contains(interest);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedInterests.remove(interest);
                                } else if (_selectedInterests.length < 5) {
                                  _selectedInterests.add(interest);
                                }
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                gradient: isSelected ? PremiumTheme.primaryGradient : null,
                                color: isSelected ? null : Colors.white,
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: isSelected 
                                    ? Colors.transparent 
                                    : PremiumTheme.border,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 5,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Text(
                                interest,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected ? Colors.white : PremiumTheme.textPrimary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
              
              // Continue Button
              Padding(
                padding: EdgeInsets.all(24.w),
                child: PremiumButton(
                  text: 'Complete Setup',
                  onPressed: _canContinue() ? _onComplete : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _canContinue() {
    return _nameController.text.isNotEmpty && 
           _bioController.text.isNotEmpty && 
           _selectedInterests.isNotEmpty;
  }

  void _onComplete() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRouter.discovery,
      (route) => false,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}