import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../../../core/themes/colors.dart';
import '../../../../../core/utils/extensions.dart';
import '../../bloc/auth_bloc.dart';
import '../../widgets/gradient_button.dart';

class OtpVerificationPage extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationPage({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage>
    with TickerProviderStateMixin {
  final _otpController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  String _currentOtp = '';
  bool _isOtpComplete = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _verifyOtp() {
    if (_isOtpComplete) {
      context.read<AuthBloc>().add(
        VerifyPhoneOtpEvent(
          phoneNumber: widget.phoneNumber,
          otp: _currentOtp,
        ),
      );
    }
  }

  void _resendOtp() {
    context.read<AuthBloc>().add(
      SendPhoneOtpEvent(phoneNumber: widget.phoneNumber),
    );
    context.showSuccessSnackBar('OTP sent successfully');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 60.h),
                    _buildHeader(),
                    SizedBox(height: 60.h),
                    _buildOtpInput(),
                    SizedBox(height: 40.h),
                    _buildVerifyButton(),
                    SizedBox(height: 30.h),
                    _buildResendSection(),
                    const Spacer(),
                    _buildBackButton(),
                    SizedBox(height: 30.h),
                  ],
                ),
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
        Text(
          'Verify Phone',
          style: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'Enter the 6-digit code sent to',
          style: TextStyle(
            fontSize: 16.sp,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          widget.phoneNumber,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildOtpInput() {
    return PinCodeTextField(
      appContext: context,
      length: 6,
      controller: _otpController,
      keyboardType: TextInputType.number,
      animationType: AnimationType.fade,
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(12.r),
        fieldHeight: 56.h,
        fieldWidth: 48.w,
        activeFillColor: AppColors.surface,
        inactiveFillColor: AppColors.surface,
        selectedFillColor: AppColors.surface,
        activeColor: AppColors.primary,
        inactiveColor: AppColors.border,
        selectedColor: AppColors.primary,
        borderWidth: 2,
      ),
      enableActiveFill: true,
      onCompleted: (value) {
        setState(() {
          _currentOtp = value;
          _isOtpComplete = true;
        });
      },
      onChanged: (value) {
        setState(() {
          _currentOtp = value;
          _isOtpComplete = value.length == 6;
        });
      },
    );
  }

  Widget _buildVerifyButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        
        return GradientButton(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6B9D), Color(0xFFFF8E9B)],
          ),
          child: Text(
            'Verify OTP',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          onPressed: _isOtpComplete && !isLoading ? _verifyOtp : null,
        );
      },
    );
  }

  Widget _buildResendSection() {
    return Center(
      child: Column(
        children: [
          Text(
            "Didn't receive the code?",
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: _resendOtp,
            child: Text(
              'Resend OTP',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Center(
      child: TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(
          'Back to Login',
          style: TextStyle(
            fontSize: 16.sp,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}