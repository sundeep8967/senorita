import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/themes/premium_theme.dart';
import '../../../../core/navigation/app_router.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PremiumTheme.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: const BoxDecoration(
                  gradient: PremiumTheme.primaryGradient,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40.w,
                            height: 40.h,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          'Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          width: 40.w,
                          height: 40.h,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.settings,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30.h),
                    // Profile Image
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 60.r,
                          backgroundImage: const NetworkImage(
                            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 36.w,
                            height: 36.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color: PremiumTheme.primaryPink,
                              size: 18.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Emma Johnson',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '25 years old',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Profile Options
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    _buildProfileOption(
                      icon: Icons.edit,
                      title: 'Edit Profile',
                      subtitle: 'Update your information',
                      onTap: () {},
                    ),
                    _buildProfileOption(
                      icon: Icons.photo_library,
                      title: 'Manage Photos',
                      subtitle: 'Add or remove photos',
                      onTap: () {},
                    ),
                    _buildProfileOption(
                      icon: Icons.location_on,
                      title: 'Location',
                      subtitle: 'Los Angeles, CA',
                      onTap: () {},
                    ),
                    _buildProfileOption(
                      icon: Icons.notifications,
                      title: 'Notifications',
                      subtitle: 'Manage your notifications',
                      onTap: () {},
                    ),
                    _buildProfileOption(
                      icon: Icons.privacy_tip,
                      title: 'Privacy',
                      subtitle: 'Control your privacy settings',
                      onTap: () {},
                    ),
                    _buildProfileOption(
                      icon: Icons.help,
                      title: 'Help & Support',
                      subtitle: 'Get help when you need it',
                      onTap: () {},
                    ),
                    _buildProfileOption(
                      icon: Icons.logout,
                      title: 'Sign Out',
                      subtitle: 'Sign out of your account',
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRouter.welcome,
                          (route) => false,
                        );
                      },
                      isDestructive: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        leading: Container(
          width: 44.w,
          height: 44.h,
          decoration: BoxDecoration(
            color: isDestructive 
              ? PremiumTheme.error.withValues(alpha: 0.1)
              : PremiumTheme.primaryPink.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            icon,
            color: isDestructive ? PremiumTheme.error : PremiumTheme.primaryPink,
            size: 20.sp,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: isDestructive ? PremiumTheme.error : PremiumTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14.sp,
            color: PremiumTheme.textSecondary,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: PremiumTheme.textSecondary,
          size: 16.sp,
        ),
        onTap: onTap,
      ),
    );
  }
}