import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/themes/colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../authentication/domain/entities/user_profile.dart';

class FemaleProfileSetupPage extends StatefulWidget {
  final String phoneNumber;
  final String? email;

  const FemaleProfileSetupPage({
    super.key,
    required this.phoneNumber,
    this.email,
  });

  @override
  State<FemaleProfileSetupPage> createState() => _FemaleProfileSetupPageState();
}

class _FemaleProfileSetupPageState extends State<FemaleProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _cityController = TextEditingController();
  final _areaController = TextEditingController();
  final _pinCodeController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _emailController = TextEditingController();
  
  DateTime? _selectedDate;
  File? _profilePhoto;
  List<String> _selectedInterests = [];
  CabPreference? _cabPreference;
  List<String> _preferredMeetingTimes = [];
  bool _isLoading = false;
  int _currentStep = 0;

  final List<String> _availableInterests = [
    'Travel', 'Food', 'Music', 'Movies', 'Sports', 'Reading',
    'Photography', 'Art', 'Dancing', 'Cooking', 'Gaming', 'Fitness',
    'Nature', 'Technology', 'Fashion', 'Yoga', 'Coffee', 'Wine',
    'Adventure', 'Beach', 'Mountains', 'Pets', 'Cars', 'Books'
  ];

  final List<String> _availableMeetingTimes = [
    'Morning (9 AM - 12 PM)',
    'Afternoon (12 PM - 5 PM)',
    'Evening (5 PM - 8 PM)',
    'Night (8 PM - 11 PM)',
    'Weekend Only',
    'Flexible'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.email != null) {
      _emailController.text = widget.email!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    _pinCodeController.dispose();
    _emergencyContactController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickProfilePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _profilePhoto = File(pickedFile.path);
      });
    }
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

    if (picked != null) {
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

  void _toggleMeetingTime(String time) {
    setState(() {
      if (_preferredMeetingTimes.contains(time)) {
        _preferredMeetingTimes.remove(time);
      } else {
        _preferredMeetingTimes.add(time);
      }
    });
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (!_validateBasicInfo()) return;
    } else if (_currentStep == 1) {
      if (!_validatePhotoAndInterests()) return;
    }

    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    } else {
      _completeProfile();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  bool _validateBasicInfo() {
    if (!_formKey.currentState!.validate()) return false;
    
    if (_selectedDate == null) {
      context.showErrorSnackBar('Please select your date of birth');
      return false;
    }

    final age = DateTime.now().year - _selectedDate!.year;
    if (age < 18) {
      context.showErrorSnackBar('You must be at least 18 years old');
      return false;
    }

    return true;
  }

  bool _validatePhotoAndInterests() {
    if (_profilePhoto == null) {
      context.showErrorSnackBar('Please add a profile photo');
      return false;
    }

    return true;
  }

  Future<void> _completeProfile() async {
    setState(() => _isLoading = true);

    try {
      // Simulate API call to create profile
      await Future.delayed(const Duration(seconds: 2));
      
      context.showSuccessSnackBar('Profile created successfully!');
      
      // Navigate to main app
      Navigator.of(context).pushReplacementNamed('/discovery');
    } catch (e) {
      context.showErrorSnackBar('Failed to create profile. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Complete Your Profile',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        leading: _currentStep > 0
            ? IconButton(
                onPressed: _previousStep,
                icon: Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                ),
              )
            : null,
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.w),
                child: _buildCurrentStep(),
              ),
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index <= _currentStep;
          
          return Expanded(
            child: Container(
              height: 4.h,
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              decoration: BoxDecoration(
                color: isActive 
                    ? AppColors.primary 
                    : AppColors.border,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildBasicInfoStep();
      case 1:
        return _buildPhotoAndInterestsStep();
      case 2:
        return _buildPreferencesAndSafetyStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBasicInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basic Information',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Let\'s start with the basics',
          style: TextStyle(
            fontSize: 16.sp,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 32.h),
        
        // Name field
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Full Name *',
            hintText: 'Enter your full name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          validator: Validators.validateName,
        ),
        
        SizedBox(height: 16.h),
        
        // Date of birth
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : 'Date of Birth *',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: _selectedDate != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: AppColors.textSecondary,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),
        
        SizedBox(height: 16.h),
        
        // City field
        TextFormField(
          controller: _cityController,
          decoration: InputDecoration(
            labelText: 'City *',
            hintText: 'Where are you located?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'City is required';
            }
            return null;
          },
        ),
        
        SizedBox(height: 16.h),
        
        // Area field
        TextFormField(
          controller: _areaController,
          decoration: InputDecoration(
            labelText: 'Area/Locality *',
            hintText: 'For cab pickup location',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Area is required for cab pickup';
            }
            return null;
          },
        ),
        
        SizedBox(height: 16.h),
        
        // Pin code field
        TextFormField(
          controller: _pinCodeController,
          decoration: InputDecoration(
            labelText: 'Pin Code *',
            hintText: 'Required for location services',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Pin code is required';
            }
            if (value.length != 6) {
              return 'Please enter a valid 6-digit pin code';
            }
            return null;
          },
        ),
        
        SizedBox(height: 16.h),
        
        // Bio field (optional)
        TextFormField(
          controller: _bioController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Short Bio (Optional)',
            hintText: 'Tell us about yourself...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoAndInterestsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photo & Interests',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Show your personality',
          style: TextStyle(
            fontSize: 16.sp,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 32.h),
        
        // Profile photo section
        Text(
          'Profile Photo *',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),
        Center(
          child: GestureDetector(
            onTap: _pickProfilePhoto,
            child: Container(
              width: 150.w,
              height: 150.h,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(75.r),
                border: Border.all(
                  color: AppColors.border,
                  width: 2,
                ),
              ),
              child: _profilePhoto != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(75.r),
                      child: Image.file(
                        _profilePhoto!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt,
                          size: 40.sp,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Add Photo',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        
        SizedBox(height: 32.h),
        
        // Interests section (optional)
        Text(
          'Interests (Optional)',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Select up to 5 interests',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 16.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: _availableInterests.map((interest) {
            final isSelected = _selectedInterests.contains(interest);
            return GestureDetector(
              onTap: () => _toggleInterest(interest),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 8.h,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Text(
                  interest,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPreferencesAndSafetyStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferences & Safety',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Help us keep you safe',
          style: TextStyle(
            fontSize: 16.sp,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 32.h),
        
        // Cab preference
        Text(
          'Cab Preference',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildCabOption(CabPreference.ola, 'Ola'),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildCabOption(CabPreference.uber, 'Uber'),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildCabOption(CabPreference.any, 'Any'),
            ),
          ],
        ),
        
        SizedBox(height: 32.h),
        
        // Preferred meeting times
        Text(
          'Preferred Meeting Times',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'When are you usually available?',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 16.h),
        Column(
          children: _availableMeetingTimes.map((time) {
            final isSelected = _preferredMeetingTimes.contains(time);
            return GestureDetector(
              onTap: () => _toggleMeetingTime(time),
              child: Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.check_circle : Icons.circle_outlined,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      size: 20.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        time,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        
        SizedBox(height: 32.h),
        
        // Emergency contact (optional)
        TextFormField(
          controller: _emergencyContactController,
          decoration: InputDecoration(
            labelText: 'Emergency Contact (Optional)',
            hintText: 'Phone number of trusted contact',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildCabOption(CabPreference preference, String label) {
    final isSelected = _cabPreference == preference;
    return GestureDetector(
      onTap: () {
        setState(() {
          _cabPreference = preference;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16.sp,
              color: isSelected ? AppColors.primary : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    width: 24.w,
                    height: 24.h,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    _currentStep == 2 ? 'Complete Profile' : 'Continue',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}