import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../core/themes/colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../domain/entities/payment.dart';
import '../../../meetup/domain/entities/meetup.dart';

class EnhancedPaymentScreen extends StatefulWidget {
  final Map<String, dynamic> profile;
  final String package;
  final String price;

  const EnhancedPaymentScreen({
    super.key,
    required this.profile,
    required this.package,
    required this.price,
  });

  @override
  State<EnhancedPaymentScreen> createState() => _EnhancedPaymentScreenState();
}

class _EnhancedPaymentScreenState extends State<EnhancedPaymentScreen> {
  late Razorpay _razorpay;
  bool _isProcessing = false;
  String? _selectedHotel;
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  String? _userLocation;

  final List<Map<String, String>> _hotels = [
    {
      'id': 'hotel_1',
      'name': 'The Grand Plaza',
      'location': 'City Center',
      'rating': '4.8',
      'amenities': 'Fine Dining, Rooftop Bar, Valet Parking',
      'image': 'https://images.unsplash.com/photo-1566073771259-6a8506099945'
    },
    {
      'id': 'hotel_2', 
      'name': 'Luxury Suites',
      'location': 'Business District',
      'rating': '4.6',
      'amenities': 'Premium Restaurant, Spa, Concierge',
      'image': 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa'
    },
    {
      'id': 'hotel_3',
      'name': 'Royal Heritage',
      'location': 'Downtown',
      'rating': '4.7',
      'amenities': 'Multi-cuisine, Live Music, Garden Seating',
      'image': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4'
    },
  ];

  final List<String> _timeSlots = [
    '12:00 PM - 2:00 PM',
    '2:00 PM - 4:00 PM', 
    '4:00 PM - 6:00 PM',
    '6:00 PM - 8:00 PM',
    '8:00 PM - 10:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _getUserLocation();
  }

  void _getUserLocation() {
    // Simulate getting user location
    setState(() {
      _userLocation = "123 Main Street, Mumbai, Maharashtra";
    });
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    setState(() {
      _isProcessing = false;
    });
    
    // Navigate to meetup confirmation screen
    Navigator.pushReplacementNamed(
      context,
      '/meetup-confirmation',
      arguments: {
        'paymentId': response.paymentId,
        'profile': widget.profile,
        'package': widget.package,
        'hotel': _selectedHotel,
        'date': _selectedDate,
        'timeSlot': _selectedTimeSlot,
        'userLocation': _userLocation,
      },
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      _isProcessing = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Failed: ${response.message}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() {
      _isProcessing = false;
    });
  }

  void _processPayment() {
    if (_selectedHotel == null || _selectedDate == null || _selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select hotel, date and time slot'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final amount = int.parse(widget.price.replaceAll('₹', '').replaceAll(',', '')) * 100; // Convert to paise

    var options = {
      'key': 'rzp_test_1DP5mmOlF5G5ag', // Replace with your Razorpay key
      'amount': amount,
      'name': 'Senorita Dating',
      'description': '${widget.package} with ${widget.profile['name']}',
      'prefill': {
        'contact': '9876543210',
        'email': 'user@example.com'
      },
      'theme': {
        'color': '#FF6B9D'
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Booking'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Summary
            _buildProfileSummary(),
            SizedBox(height: 24.h),
            
            // Package Details
            _buildPackageDetails(),
            SizedBox(height: 24.h),
            
            // Hotel Selection
            _buildHotelSelection(),
            SizedBox(height: 24.h),
            
            // Date & Time Selection
            _buildDateTimeSelection(),
            SizedBox(height: 24.h),
            
            // Location Info
            _buildLocationInfo(),
            SizedBox(height: 24.h),
            
            // What's Included
            _buildIncludedFeatures(),
            SizedBox(height: 32.h),
            
            // Payment Button
            _buildPaymentButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSummary() {
    return Container(
      padding: EdgeInsets.all(16.w),
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundImage: NetworkImage(widget.profile['image']),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Meetup with ${widget.profile['name']}',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${widget.profile['age']} years old • ${widget.profile['distance']} km away',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageDetails() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.package,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                widget.price,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            widget.package == 'Coffee Date' 
                ? 'Perfect for a casual first meetup with beverages and light snacks'
                : 'Elegant dining experience with full course meal and premium ambiance',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[700],
            ),
          ),
        ],
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
          ),
        ),
        SizedBox(height: 12.h),
        ...(_hotels.map((hotel) => _buildHotelCard(hotel)).toList()),
      ],
    );
  }

  Widget _buildHotelCard(Map<String, String> hotel) {
    final isSelected = _selectedHotel == hotel['id'];
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedHotel = hotel['id'];
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
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
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.network(
                hotel['image']!,
                width: 60.w,
                height: 60.h,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hotel['name']!,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${hotel['location']} • ⭐ ${hotel['rating']}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    hotel['amenities']!,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey[500],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
      ),
    );
  }

  Widget _buildDateTimeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Date & Time',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),
        
        // Date Selection
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now().add(const Duration(days: 1)),
              firstDate: DateTime.now().add(const Duration(days: 1)),
              lastDate: DateTime.now().add(const Duration(days: 30)),
            );
            if (date != null) {
              setState(() {
                _selectedDate = date;
              });
            }
          },
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDate != null 
                      ? '📅 ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                      : 'Select Date',
                  style: TextStyle(fontSize: 16.sp),
                ),
                const Icon(Icons.calendar_today),
              ],
            ),
          ),
        ),
        
        SizedBox(height: 12.h),
        
        // Time Slot Selection
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: _timeSlots.map((slot) {
            final isSelected = _selectedTimeSlot == slot;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTimeSlot = slot;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: AppColors.primary),
                ),
                child: Text(
                  slot,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.primary,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLocationInfo() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.blue[600]),
              SizedBox(width: 8.w),
              Text(
                'Your Location',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            _userLocation ?? 'Getting your location...',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.blue[700],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '🚗 Free cab will be arranged for the girl from her location to the selected venue',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.blue[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncludedFeatures() {
    final features = [
      '✅ Venue booking at selected hotel',
      '✅ ${widget.package == 'Coffee Date' ? 'Beverages and snacks' : 'Full course meal'}',
      '✅ Free cab for the girl (pickup & drop)',
      '✅ Safe and verified environment',
      '✅ Emergency support available',
      '✅ 2-hour time slot guaranteed',
    ];

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What\'s Included',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
          SizedBox(height: 12.h),
          ...features.map((feature) => Padding(
            padding: EdgeInsets.only(bottom: 4.h),
            child: Text(
              feature,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.green[700],
              ),
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildPaymentButton() {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: _isProcessing
            ? SizedBox(
                width: 24.w,
                height: 24.h,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Pay ${widget.price} & Send Meetup Request',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}