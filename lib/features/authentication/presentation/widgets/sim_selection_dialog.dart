import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/themes/colors.dart';

class SimSelectionDialog extends StatelessWidget {
  final List<Map<String, dynamic>> simDetails;
  final Function(String) onSimSelected;

  const SimSelectionDialog({
    super.key,
    required this.simDetails,
    required this.onSimSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.sim_card,
                    color: AppColors.primary,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Multiple SIMs Detected',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Choose which number to use',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 24.h),
            
            // SIM Cards List
            ...simDetails.map((sim) => _buildSimCard(sim)).toList(),
            
          ],
        ),
      ),
    );
  }

  Widget _buildSimCard(Map<String, dynamic> sim) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onSimSelected(sim['phoneNumber']),
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.border,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                // SIM Icon with slot indicator
                Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: _getCarrierColor(sim['carrierName']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sim_card,
                        color: _getCarrierColor(sim['carrierName']),
                        size: 20.sp,
                      ),
                      Text(
                        '${sim['slotIndex'] + 1}',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: _getCarrierColor(sim['carrierName']),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(width: 16.w),
                
                // SIM Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sim['displayName'],
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        sim['phoneNumber'],
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Container(
                            width: 8.w,
                            height: 8.h,
                            decoration: BoxDecoration(
                              color: sim['isActive'] ? AppColors.success : AppColors.textHint,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            sim['isActive'] ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: sim['isActive'] ? AppColors.success : AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Arrow
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16.sp,
                  color: AppColors.textHint,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Color _getCarrierColor(String carrierName) {
    switch (carrierName.toLowerCase()) {
      case 'airtel':
        return const Color(0xFFE60012); // Airtel Red
      case 'jio':
        return const Color(0xFF0066CC); // Jio Blue
      case 'vi':
      case 'vodafone':
        return const Color(0xFFE60000); // Vodafone Red
      case 'bsnl':
        return const Color(0xFF1B5E20); // BSNL Green
      default:
        return AppColors.primary;
    }
  }
}