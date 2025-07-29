import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/themes/premium_theme.dart';

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
              color: PremiumTheme.textSecondary,
              size: 60.w,
              onPressed: widget.onPass,
            ),
            
            // Super Like Button
            _buildActionButton(
              controller: _superLikeController,
              icon: Icons.star,
              color: PremiumTheme.accentOrange,
              size: 50.w,
              onPressed: widget.onSuperLike,
            ),
            
            // Like Button
            _buildActionButton(
              controller: _likeController,
              icon: Icons.favorite,
              color: PremiumTheme.primaryPink,
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
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    PremiumTheme.primaryPink,
                    PremiumTheme.accentOrange,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(28.r),
                boxShadow: [
                  BoxShadow(
                    color: PremiumTheme.primaryPink.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
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
                      Text(
                        'Meet for Dinner',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          '₹500+',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
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
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
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