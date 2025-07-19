import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/themes/colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../authentication/domain/entities/user_profile.dart';
import '../widgets/photo_upload_section.dart';
import '../widgets/preferences_section.dart';

class MaleProfileSetupPage extends StatefulWidget {
  final String phoneNumber;
  final String? email;

  const MaleProfileSetupPage({
    super.key,
    required this.phoneNumber,
    this.email,
  });

  @override
  State<MaleProfileSetupPage> createState() => _MaleProfileSetupPageState();
}

class _MaleProfileSetupPageState extends State<MaleProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _cityController = TextEditingController();
  final _emailController = TextEditingController();
  
  DateTime? _selectedDate;
  File? _profilePhoto;
  List<File> _additionalPhotos = [];
  List<String> _selectedInterests = [];
  UserPreferences? _preferences;
  bool _isLoading = false;
  int _currentStep = 0;

  final List<String> _availableInterests = [
    'Travel', 'Food', 'Music', 'Movies', 'Sports', 'Reading',
    'Photography', 'Art', 'Dancing', 'Cooking', 'Gaming', 'Fitness',
    'Nature', 'Technology', 'Fashion', 'Yoga', 'Coffee', 'Wine',
    'Adventure', 'Beach', 'Mountains', 'Pets', 'Cars', 'Books'
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

  void _nextStep() {
    if (_currentStep == 0) {
      if (!_validateBasicInfo()) return;
    } else if (_currentStep == 1) {
      if (!_validatePhotosAndInterests()) return;
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

  bool _validatePhotosAndInterests() {
    if (_profilePhoto == null) {
      context.showErrorSnackBar('Please add a profile photo');
      return false;
    }

    if (_selectedInterests.length < 3) {
      context.showErrorSnackBar('Please select at least 3 interests');
      return false;
    }

    return true;
  }

  Future<void> _completeProfile() async {
    if (_preferences == null) {
      context.showErrorSnackBar('Please set your preferences');
      return;
    }

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
          // Progress indicator
          _buildProgressIndicator(),
          
          // Content
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.w),
                child: _buildCurrentStep(),
              ),
            ),
          ),
          
          // Bottom button
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
          final isCompleted = index < _currentStep;
          
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
        return _buildPhotosAndInterestsStep();
      case 2:
        return _buildPreferencesStep();
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
        
        // Email field
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email (Optional)',
            hintText: 'For receipts and notifications',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              return Validators.validateEmail(value);
            }
            return null;
          },
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
        
        // Bio field
        TextFormField(
          controller: _bioController,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: 'Short Bio *',
            hintText: 'Tell us about yourself...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          validator: Validators.validateBio,
        ),
      ],
    );
  }

  Widget _buildPhotosAndInterestsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photos & Interests',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Show your best self',
          style: TextStyle(
            fontSize: 16.sp,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 32.h),
        
        PhotoUploadSection(
          profilePhoto: _profilePhoto,
          additionalPhotos: _additionalPhotos,
          onProfilePhotoTap: _pickProfilePhoto,
          onAddPhoto: (photo) {
            setState(() {
              _additionalPhotos.add(photo);
            });
          },
          onRemovePhoto: (index) {
            setState(() {
              _additionalPhotos.removeAt(index);
            });
          },
        ),
        
        SizedBox(height: 32.h),
        
        // Interests section
        Text(
          'Interests',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Select at least 3 interests (max 5)',
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

  Widget _buildPreferencesStep() {
    return PreferencesSection(
      onPreferencesChanged: (preferences) {
        setState(() {
          _preferences = preferences;
        });
      },
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