import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/themes/colors.dart';
import '../../../../../core/services/phone_service.dart';
import '../../../../profile/presentation/pages/profile_setup/profile_setup_page.dart';
import '../../widgets/sim_selection_dialog.dart';
import '../../widgets/gradient_button.dart';

class PhoneAssociationPage extends StatefulWidget {
  final String userName;
  final String email;

  const PhoneAssociationPage({
    super.key,
    required this.userName,
    required this.email,
  });

  @override
  State<PhoneAssociationPage> createState() => _PhoneAssociationPageState();
}

class _PhoneAssociationPageState extends State<PhoneAssociationPage> {
  String? _selectedPhoneNumber;
  bool _isDetecting = false;
  bool _phoneDetected = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1000), () {
      _detectPhoneNumber();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40.h),
                _buildHeader(),
                SizedBox(height: 40.h),
                _buildContent(),
                SizedBox(height: 40.h), // Bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Icon(
            Icons.phone_android,
            size: 40.sp,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          'Almost Done!',
          style: TextStyle(
            fontSize: 32.sp,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Let\'s associate your phone number for a complete profile',
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildUserInfo(),
          SizedBox(height: 32.h),
          _buildPhoneDetectionSection(),
          SizedBox(height: 32.h),
          if (_phoneDetected && _selectedPhoneNumber != null)
            _buildContinueButton(),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.success.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Icon(
              Icons.check,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Logged in successfully',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  widget.userName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  widget.email,
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
    );
  }

  Widget _buildPhoneDetectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone Number Association',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'We\'ll detect your SIM card number automatically',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 24.h),
        
        if (_isDetecting)
          _buildDetectingState()
        else if (_phoneDetected && _selectedPhoneNumber != null)
          _buildDetectedState()
        else
          _buildDetectButton(),
      ],
    );
  }

  Widget _buildDetectingState() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24.w,
            height: 24.h,
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          ),
          SizedBox(width: 16.w),
          Text(
            'Detecting SIM cards...',
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectedState() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.success.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.sim_card,
            color: AppColors.success,
            size: 24.sp,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phone Number Detected',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _selectedPhoneNumber!,
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _detectPhoneNumber,
            child: Text(
              'Change',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _detectPhoneNumber,
        icon: Icon(
          Icons.sim_card,
          size: 20.sp,
          color: AppColors.primary,
        ),
        label: Text(
          'Detect SIM Number',
          style: TextStyle(
            fontSize: 16.sp,
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.primary, width: 2),
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return GradientButton(
      onPressed: _handleContinue,
      gradient: AppColors.primaryGradient,
      child: Text(
        'Continue to Profile Setup',
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  void _detectPhoneNumber() async {
    setState(() {
      _isDetecting = true;
      _phoneDetected = false;
      _selectedPhoneNumber = null;
    });

    try {
      final simDetails = await PhoneService.getSimDetails();
      
      setState(() => _isDetecting = false);
      
      if (simDetails.isEmpty) {
        _showNoSimDialog();
        return;
      }
      
      if (simDetails.length == 1) {
        final phoneNumber = simDetails.first['phoneNumber'];
        setState(() {
          _selectedPhoneNumber = phoneNumber;
          _phoneDetected = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('SIM detected and associated with your account!'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        _showSimSelectionDialog(simDetails);
      }
    } catch (e) {
      setState(() => _isDetecting = false);
      print('Error detecting phone number: $e');
    }
  }

  void _showSimSelectionDialog(List<Map<String, dynamic>> simDetails) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SimSelectionDialog(
        simDetails: simDetails,
        onSimSelected: (selectedNumber) {
          Navigator.of(context).pop();
          
          setState(() {
            _selectedPhoneNumber = selectedNumber;
            _phoneDetected = true;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Phone number associated with your account!'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 3),
            ),
          );
        },
      ),
    );
  }

  void _showNoSimDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(
              Icons.sim_card_alert,
              color: AppColors.error,
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Text(
              'SIM Card Required',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Senorita requires a valid SIM card for phone verification.',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: AppColors.info.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Why do we need this?',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.info,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '- Verify your identity without OTP\n- Ensure genuine user profiles\n- Enable premium meetup features',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _detectPhoneNumber();
            },
            child: Text(
              'Try Again',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text('Exit App'),
          ),
        ],
      ),
    );
  }

  void _handleContinue() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ProfileSetupPage(
          phoneNumber: _selectedPhoneNumber!,
          userName: widget.userName,
          email: widget.email,
        ),
      ),
    );
  }
}