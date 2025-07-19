import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../../core/themes/colors.dart';
import '../../../../../core/utils/extensions.dart';
import '../../../../../core/utils/validators.dart';

class ProfileSetupPage extends StatefulWidget {
  final String phoneNumber;
  final String? userName;
  final String? email;

  const ProfileSetupPage({
    super.key,
    required this.phoneNumber,
    this.userName,
    this.email,
  });

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _professionController = TextEditingController();
  
  DateTime? _selectedDate;
  List<File> _selectedImages = [];
  List<String> _selectedInterests = [];
  bool _isLoading = false;
  
  final List<String> _availableInterests = [
    'Travel', 'Food', 'Music', 'Movies', 'Sports', 'Reading',
    'Photography', 'Art', 'Dancing', 'Cooking', 'Gaming', 'Fitness',
    'Nature', 'Technology', 'Fashion', 'Yoga', 'Coffee', 'Wine',
    'Adventure', 'Beach', 'Mountains', 'Pets', 'Cars', 'Books'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.userName != null) {
      _nameController.text = widget.userName!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _professionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_selectedImages.length >= 6) {
      context.showErrorSnackBar('You can only add up to 6 photos');
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(File(pickedFile.path));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 80)),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else if (_selectedInterests.length < 5) {
        _selectedInterests.add(interest);
      } else {
        context.showErrorSnackBar('You can select up to 5 interests');
      }
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedImages.isEmpty) {
      context.showErrorSnackBar('Please add at least one photo');
      return;
    }
    
    if (_selectedDate == null) {
      context.showErrorSnackBar('Please select your date of birth');
      return;
    }
    
    if (_selectedInterests.length < 3) {
      context.showErrorSnackBar('Please select at least 3 interests');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      context.showSuccessSnackBar('Profile created successfully!');
      
      // Navigate to main app
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      context.showErrorSnackBar('Failed to create profile. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
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
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40.h),
                _buildHeader(),
                SizedBox(height: 40.h),
                Expanded(
                  child: Container(
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
                      children: [
                        Text(
                          'Profile Setup Coming Soon!',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        if (widget.userName != null) ...[
                          Text(
                            'Welcome, ${widget.userName}!',
                            style: TextStyle(
                              fontSize: 18.sp,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          if (widget.email != null)
                            Text(
                              widget.email!,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          SizedBox(height: 16.h),
                        ],
                        Text(
                          'Associated phone number:',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.phone,
                                color: AppColors.primary,
                                size: 20.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                widget.phoneNumber,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 32.h),
                        Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 80.sp,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'SIM Authentication Successful!',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'No OTP needed - your SIM card verified your identity automatically.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Icon(
            Icons.person_add,
            size: 32.sp,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'Welcome to',
          style: TextStyle(
            fontSize: 20.sp,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w300,
          ),
        ),
        Text(
          'Senorita',
          style: TextStyle(
            fontSize: 36.sp,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Your premium dating journey starts here',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}