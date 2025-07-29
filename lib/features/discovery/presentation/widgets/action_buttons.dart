import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';
import '../../../../core/themes/ios_glassmorphism_theme.dart';

class ActionButtons extends StatefulWidget {
  final VoidCallback? onPass;
  final VoidCallback? onLike;
  final VoidCallback? onSuperLike;
  final VoidCallback? onPaidSwipe;

  const ActionButtons({
    super.key,
    this.onPass,
    this.onLike,
    this.onSuperLike,
    this.onPaidSwipe,
  });

  @override
  State<ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<ActionButtons>
    with TickerProviderStateMixin {
  late AnimationController _passController;
  late AnimationController _likeController;
  late AnimationController _superLikeController;
  late AnimationController _paidSwipeController;

  @override
  void initState() {
    super.initState();
    _passController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _likeController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _superLikeController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _paidSwipeController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _passController.dispose();
    _likeController.dispose();
    _superLikeController.dispose();
    _paidSwipeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Premium Paid Swipe Button
        if (widget.onPaidSwipe != null)
          Container(
            margin: EdgeInsets.only(bottom: 16.h),
            child: _buildPaidSwipeButton(),
          ),
        
        // Regular Action Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Pass Button
            _buildActionButton(
              controller: _passController,
              icon: Icons.close,
              color: IOSGlassmorphismTheme.iosBlue,
              size: 60.w,
              onPressed: widget.onPass,
            ),
            
            // Super Like Button
            _buildActionButton(
              controller: _superLikeController,
              icon: Icons.star,
              color: IOSGlassmorphismTheme.iosOrange,
              size: 50.w,
              onPressed: widget.onSuperLike,
            ),
            
            // Like Button
            _buildActionButton(
              controller: _likeController,
              icon: Icons.favorite,
              color: IOSGlassmorphismTheme.iosPink,
              size: 60.w,
              onPressed: widget.onLike,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaidSwipeButton() {
    return GestureDetector(
      onTapDown: (_) => _paidSwipeController.forward(),
      onTapUp: (_) => _paidSwipeController.reverse(),
      onTapCancel: () => _paidSwipeController.reverse(),
      onTap: widget.onPaidSwipe,
      child: AnimatedBuilder(
        animation: _paidSwipeController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 - (_paidSwipeController.value * 0.05),
            child: Container(
              width: double.infinity,
              height: 56.h,
              decoration: IOSGlassmorphismTheme.premiumButton(
                gradient: IOSGlassmorphismTheme.primaryGradient,
                borderRadius: 28,
                shadowColor: IOSGlassmorphismTheme.iosPink,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28.r),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28.r),
                      onTap: widget.onPaidSwipe,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.restaurant,
                            color: Colors.white,
                            size: 24.sp,
                          ),
                          SizedBox(width: 12.w),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Meet for Dinner',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              Text(
                                'She pays nothing!',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  letterSpacing: -0.1,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '₹500+',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton({
    required AnimationController controller,
    required IconData icon,
    required Color color,
    required double size,
    required VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTapDown: (_) => controller.forward(),
      onTapUp: (_) => controller.reverse(),
      onTapCancel: () => controller.reverse(),
      onTap: onPressed,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 - (controller.value * 0.1),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                gradient: IOSGlassmorphismTheme.buttonGradient,
                shape: BoxShape.circle,
                border: Border.all(
                  color: IOSGlassmorphismTheme.glassBorder,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.1),
                    blurRadius: 1,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(size / 2),
                  onTap: onPressed,
                  child: Center(
                    child: Icon(
                      icon,
                      color: color,
                      size: (size * 0.4).sp,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}