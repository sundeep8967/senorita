import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/themes/premium_theme.dart';
import '../../../payment/domain/entities/payment.dart';
import '../../../meetup/domain/entities/meetup.dart';

/// Dialog shown to girls when they receive a paid meetup request
class GirlNotificationDialog extends StatelessWidget {
  final String boyName;
  final String boyPhoto;
  final MeetupPackage package;
  final Hotel hotel;
  final DateTime scheduledDateTime;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const GirlNotificationDialog({
    super.key,
    required this.boyName,
    required this.boyPhoto,
    required this.package,
    required this.hotel,
    required this.scheduledDateTime,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: PremiumTheme.primaryGradient,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  _buildBoyInfo(),
                  SizedBox(height: 20.h),
                  _buildMeetupDetails(),
                  SizedBox(height: 20.h),
                  _buildFreePerks(),
                  SizedBox(height: 24.h),
                  _buildActionButtons(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.favorite,
            color: Colors.white,
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'You have a meetup request!',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoyInfo() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              width: 60.w,
              height: 60.w,
              color: Colors.white.withValues(alpha: 0.3),
              child: boyPhoto.isNotEmpty
                  ? Image.network(boyPhoto, fit: BoxFit.cover)
                  : Icon(Icons.person, color: Colors.white, size: 30.sp),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$boyName wants to meet you',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'He has already paid ₹${package.price}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetupDetails() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Meetup Details',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12.h),
          _buildDetailRow(Icons.restaurant, package.name),
          _buildDetailRow(Icons.location_on, hotel.name),
          _buildDetailRow(Icons.access_time, 
            '${scheduledDateTime.day}/${scheduledDateTime.month} at ${scheduledDateTime.hour}:00'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFreePerks() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: Colors.yellow, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Everything FREE for you!',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...package.includes.map((perk) => Padding(
            padding: EdgeInsets.only(bottom: 4.h),
            child: Text(
              perk,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: onDecline,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
                side: const BorderSide(color: Colors.white),
              ),
            ),
            child: Text(
              'Maybe Later',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: onAccept,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: PremiumTheme.primaryPink,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              'Accept & Meet! 🎉',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}