import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/themes/colors.dart';
import '../../../authentication/domain/entities/user_profile.dart';
import '../../../authentication/domain/entities/user.dart';

class PreferencesSection extends StatefulWidget {
  final Function(UserPreferences) onPreferencesChanged;

  const PreferencesSection({
    super.key,
    required this.onPreferencesChanged,
  });

  @override
  State<PreferencesSection> createState() => _PreferencesSectionState();
}

class _PreferencesSectionState extends State<PreferencesSection> {
  int _minAge = 18;
  int _maxAge = 35;
  Gender _preferredGender = Gender.female;
  double _maxDistance = 25.0;
  final List<String> _preferredCities = [];
  final List<String> _dealBreakers = [];

  final List<String> _availableCities = [
    'Mumbai', 'Delhi', 'Bangalore', 'Chennai', 'Kolkata', 'Hyderabad',
    'Pune', 'Ahmedabad', 'Jaipur', 'Surat', 'Lucknow', 'Kanpur'
  ];

  final List<String> _availableDealBreakers = [
    'Smoking', 'Drinking', 'Non-vegetarian', 'Different religion',
    'Long distance', 'No job', 'Lives with parents', 'Divorced'
  ];

  @override
  void initState() {
    super.initState();
    _updatePreferences();
  }

  void _updatePreferences() {
    final preferences = UserPreferences(
      minAge: _minAge,
      maxAge: _maxAge,
      preferredGender: _preferredGender,
      maxDistance: _maxDistance,
      preferredCities: _preferredCities,
      dealBreakers: _dealBreakers,
    );
    widget.onPreferencesChanged(preferences);
  }

  void _toggleCity(String city) {
    setState(() {
      if (_preferredCities.contains(city)) {
        _preferredCities.remove(city);
      } else {
        _preferredCities.add(city);
      }
      _updatePreferences();
    });
  }

  void _toggleDealBreaker(String dealBreaker) {
    setState(() {
      if (_dealBreakers.contains(dealBreaker)) {
        _dealBreakers.remove(dealBreaker);
      } else {
        _dealBreakers.add(dealBreaker);
      }
      _updatePreferences();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dating Preferences',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Help us find your perfect match',
          style: TextStyle(
            fontSize: 16.sp,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 32.h),
        
        // Age range
        _buildAgeRange(),
        SizedBox(height: 24.h),
        
        // Preferred gender
        _buildPreferredGender(),
        SizedBox(height: 24.h),
        
        // Max distance
        _buildMaxDistance(),
        SizedBox(height: 24.h),
        
        // Preferred cities
        _buildPreferredCities(),
        SizedBox(height: 24.h),
        
        // Deal breakers
        _buildDealBreakers(),
      ],
    );
  }

  Widget _buildAgeRange() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Age Range',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Text(
              '$_minAge - $_maxAge years',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        RangeSlider(
          values: RangeValues(_minAge.toDouble(), _maxAge.toDouble()),
          min: 18,
          max: 60,
          divisions: 42,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.border,
          onChanged: (RangeValues values) {
            setState(() {
              _minAge = values.start.round();
              _maxAge = values.end.round();
              _updatePreferences();
            });
          },
        ),
      ],
    );
  }

  Widget _buildPreferredGender() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Looking for',
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
              child: _buildGenderOption(Gender.female, 'Women'),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildGenderOption(Gender.male, 'Men'),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildGenderOption(Gender.other, 'Everyone'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(Gender gender, String label) {
    final isSelected = _preferredGender == gender;
    return GestureDetector(
      onTap: () {
        setState(() {
          _preferredGender = gender;
          _updatePreferences();
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

  Widget _buildMaxDistance() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Maximum Distance',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Text(
              '${_maxDistance.round()} km',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Slider(
          value: _maxDistance,
          min: 5,
          max: 100,
          divisions: 19,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.border,
          onChanged: (double value) {
            setState(() {
              _maxDistance = value;
              _updatePreferences();
            });
          },
        ),
      ],
    );
  }

  Widget _buildPreferredCities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferred Cities (Optional)',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Select cities where you\'d like to meet people',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 16.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: _availableCities.map((city) {
            final isSelected = _preferredCities.contains(city);
            return GestureDetector(
              onTap: () => _toggleCity(city),
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
                  city,
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

  Widget _buildDealBreakers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Deal Breakers (Optional)',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Select things that are important to you',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 16.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: _availableDealBreakers.map((dealBreaker) {
            final isSelected = _dealBreakers.contains(dealBreaker);
            return GestureDetector(
              onTap: () => _toggleDealBreaker(dealBreaker),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 8.h,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.red.withOpacity(0.1) : AppColors.surface,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected ? Colors.red : AppColors.border,
                  ),
                ),
                child: Text(
                  dealBreaker,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isSelected ? Colors.red : AppColors.textPrimary,
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
}