import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/themes/colors.dart';
import '../../domain/entities/profile.dart';

class ProfileCard extends StatefulWidget {
  final Profile profile;
  final Function(SwipeAction)? onSwipe;
  final bool isBackground;

  const ProfileCard({
    super.key,
    required this.profile,
    this.onSwipe,
    this.isBackground = false,
  });

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  int _currentPhotoIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: widget.isBackground ? null : _handlePanUpdate,
      onPanEnd: widget.isBackground ? null : _handlePanEnd,
      onTap: _nextPhoto,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            children: [
              // Photo
              _buildPhotoSection(),
              
              // Photo indicators
              if (widget.profile.photos.length > 1)
                _buildPhotoIndicators(),
              
              // Gradient overlay
              _buildGradientOverlay(),
              
              // Profile info
              _buildProfileInfo(),
              
              // Swipe indicators
              if (!widget.isBackground)
                _buildSwipeIndicators(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Positioned.fill(
      child: widget.profile.photos.isNotEmpty
          ? Image.network(
              widget.profile.photos[_currentPhotoIndex],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.surface,
                  child: Icon(
                    Icons.person,
                    size: 100.sp,
                    color: AppColors.textSecondary,
                  ),
                );
              },
            )
          : Container(
              color: AppColors.surface,
              child: Icon(
                Icons.person,
                size: 100.sp,
                color: AppColors.textSecondary,
              ),
            ),
    );
  }

  Widget _buildPhotoIndicators() {
    return Positioned(
      top: 16.h,
      left: 16.w,
      right: 16.w,
      child: Row(
        children: widget.profile.photos.asMap().entries.map((entry) {
          return Expanded(
            child: Container(
              height: 3.h,
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              decoration: BoxDecoration(
                color: entry.key == _currentPhotoIndex
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: 200.h,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: 0.8),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Positioned(
      bottom: 24.h,
      left: 24.w,
      right: 24.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${widget.profile.name}, ${widget.profile.age}',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              if (widget.profile.isVerified)
                Icon(
                  Icons.verified,
                  color: AppColors.primary,
                  size: 24.sp,
                ),
            ],
          ),
          
          if (widget.profile.profession != null) ...[
            SizedBox(height: 4.h),
            Text(
              widget.profile.profession!,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
          
          if (widget.profile.distance != null) ...[
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 16.sp,
                ),
                SizedBox(width: 4.w),
                Text(
                  '${widget.profile.distance!.toStringAsFixed(1)} km away',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ],
          
          SizedBox(height: 8.h),
          Text(
            widget.profile.bio,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          
          if (widget.profile.interests.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 4.h,
              children: widget.profile.interests.take(3).map((interest) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    interest,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSwipeIndicators() {
    return const SizedBox.shrink(); // Will be implemented with gesture detection
  }

  void _nextPhoto() {
    if (widget.profile.photos.length > 1) {
      setState(() {
        _currentPhotoIndex = (_currentPhotoIndex + 1) % widget.profile.photos.length;
      });
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    // Handle swipe gestures
  }

  void _handlePanEnd(DragEndDetails details) {
    // Handle swipe completion
  }
}