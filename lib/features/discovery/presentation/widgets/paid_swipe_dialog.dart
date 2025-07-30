import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';
import '../../../../core/themes/ios_glassmorphism_theme.dart';
import '../../../../core/widgets/glassmorphism_widgets.dart';
import '../../domain/entities/profile.dart';
import '../../../payment/domain/entities/payment.dart';
import '../../../meetup/domain/entities/meetup.dart';

class PaidSwipeDialog extends StatefulWidget {
  final Profile profile;
  final Function(PackageType packageType, String hotelId, DateTime dateTime) onConfirmPaidSwipe;
  final VoidCallback onCancel;

  const PaidSwipeDialog({
    super.key,
    required this.profile,
    required this.onConfirmPaidSwipe,
    required this.onCancel,
  });

  @override
  State<PaidSwipeDialog> createState() => _PaidSwipeDialogState();
}

class _PaidSwipeDialogState extends State<PaidSwipeDialog> {
  PackageType? _selectedPackage;
  String? _selectedHotelId;
  DateTime? _selectedDateTime;

  final List<MeetupPackage> _packages = [
    const MeetupPackage(
      id: 'coffee',
      name: '☕ Coffee Date',
      price: 500,
      description: 'Perfect for a casual first meetup',
      includes: [
        '🏨 Premium cafe venue',
        '☕ Beverages for both (YOU PAY)',
        '🚗 FREE cab pickup & drop for her',
        '🛡️ Safety guarantee',
        '⏰ 2-hour time slot',
        '📞 24/7 support',
        '💰 She pays NOTHING!'
      ],
      type: PackageType.basic,
    ),
    const MeetupPackage(
      id: 'dinner',
      name: '🍽️ Dinner Date',
      price: 1000,
      description: 'Elegant dining experience',
      includes: [
        '🏨 5-star hotel restaurant',
        '🍽️ 3-course meal for both (YOU PAY)',
        '🚗 FREE cab pickup & drop for her',
        '🛡️ Premium safety guarantee',
        '⏰ 3-hour time slot',
        '📞 Dedicated concierge',
        '🎁 Welcome drink'
      ],
      type: PackageType.premium,
    ),
  ];

  final List<Hotel> _mockHotels = [
    const Hotel(
      id: 'hotel1',
      name: 'The Oberoi',
      address: 'Nariman Point, Mumbai',
      city: 'Mumbai',
      latitude: 18.9220,
      longitude: 72.8347,
      rating: 4.8,
      amenities: ['Fine Dining', 'Valet Parking', 'Concierge'],
      photos: [],
      contactNumber: '+91-22-6632-5757',
      isPartner: true,
      isActive: true,
      supportedPackages: ['coffee', 'dinner'],
      packageDetails: {},
    ),
    const Hotel(
      id: 'hotel2',
      name: 'Taj Mahal Palace',
      address: 'Apollo Bunder, Mumbai',
      city: 'Mumbai',
      latitude: 18.9217,
      longitude: 72.8330,
      rating: 4.9,
      amenities: ['Heritage Property', 'Multiple Restaurants', 'Sea View'],
      photos: [],
      contactNumber: '+91-22-6665-3366',
      isPartner: true,
      isActive: true,
      supportedPackages: ['coffee', 'dinner'],
      packageDetails: {},
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxHeight: 0.8.sh),
        decoration: BoxDecoration(
          gradient: IOSGlassmorphismTheme.primaryGradient,
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
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileInfo(),
                    SizedBox(height: 24.h),
                    _buildPackageSelection(),
                    if (_selectedPackage != null) ...[
                      SizedBox(height: 24.h),
                      _buildHotelSelection(),
                    ],
                    if (_selectedHotelId != null) ...[
                      SizedBox(height: 24.h),
                      _buildDateTimeSelection(),
                    ],
                  ],
                ),
              ),
            ),
            _buildActionButtons(),
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
              'Meet ${widget.profile.name}',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            onPressed: widget.onCancel,
            icon: Icon(
              Icons.close,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
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
              color: AppColors.primary.withValues(alpha: 0.3),
              child: widget.profile.photos.isNotEmpty
                  ? Image.network(
                      widget.profile.photos.first,
                      fit: BoxFit.cover,
                    )
                  : Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 30.sp,
                    ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.profile.name}, ${widget.profile.age}',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (widget.profile.profession != null)
                  Text(
                    widget.profile.profession!,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                if (widget.profile.distance != null)
                  Text(
                    '${widget.profile.distance!.toStringAsFixed(1)} km away',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Your Experience',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 16.h),
        ..._packages.map((package) => _buildPackageCard(package)),
      ],
    );
  }

  Widget _buildPackageCard(MeetupPackage package) {
    final isSelected = _selectedPackage == package.type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPackage = package.type;
          _selectedHotelId = null; // Reset hotel selection
          _selectedDateTime = null; // Reset date selection
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16.r),
          border: isSelected 
              ? Border.all(color: Colors.white, width: 2)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    package.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  '₹${package.price}',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: IOSGlassmorphismTheme.iosOrange,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              package.description,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 4.h,
              children: package.includes.map((feature) => Text(
                feature,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Venue',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 16.h),
        ..._mockHotels.map((hotel) => _buildHotelCard(hotel)),
      ],
    );
  }

  Widget _buildHotelCard(Hotel hotel) {
    final isSelected = _selectedHotelId == hotel.id;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedHotelId = hotel.id;
          _selectedDateTime = null; // Reset date selection
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16.r),
          border: isSelected 
              ? Border.all(color: Colors.white, width: 2)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    hotel.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: PremiumTheme.accentOrange,
                      size: 16.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      hotel.rating.toString(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              hotel.address,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              children: hotel.amenities.map((amenity) => Chip(
                label: Text(
                  amenity,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                side: BorderSide.none,
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'When would you like to meet?',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            children: [
              _buildTimeSlot('Today Evening', DateTime.now().add(const Duration(hours: 6))),
              _buildTimeSlot('Tomorrow Lunch', DateTime.now().add(const Duration(days: 1, hours: 1))),
              _buildTimeSlot('Tomorrow Evening', DateTime.now().add(const Duration(days: 1, hours: 6))),
              _buildTimeSlot('This Weekend', DateTime.now().add(const Duration(days: 2, hours: 6))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlot(String label, DateTime dateTime) {
    final isSelected = _selectedDateTime == dateTime;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDateTime = dateTime;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: isSelected 
              ? Border.all(color: Colors.white, width: 1)
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            Text(
              '${dateTime.day}/${dateTime.month} ${dateTime.hour}:00',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final canProceed = _selectedPackage != null && 
                      _selectedHotelId != null && 
                      _selectedDateTime != null;
    
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: widget.onCancel,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  side: const BorderSide(color: Colors.white),
                ),
              ),
              child: Text(
                'Cancel',
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
              onPressed: canProceed 
                  ? () => widget.onConfirmPaidSwipe(
                        _selectedPackage!,
                        _selectedHotelId!,
                        _selectedDateTime!,
                      )
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: IOSGlassmorphismTheme.iosPink,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                canProceed 
                    ? 'Confirm & Pay ₹${_packages.firstWhere((p) => p.type == _selectedPackage).price}'
                    : 'Select Options',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}