import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/themes/colors.dart';

class PhotoUploadSection extends StatelessWidget {
  final File? profilePhoto;
  final List<File> additionalPhotos;
  final VoidCallback onProfilePhotoTap;
  final Function(File) onAddPhoto;
  final Function(int) onRemovePhoto;

  const PhotoUploadSection({
    super.key,
    this.profilePhoto,
    required this.additionalPhotos,
    required this.onProfilePhotoTap,
    required this.onAddPhoto,
    required this.onRemovePhoto,
  });

  Future<void> _pickAdditionalPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      onAddPhoto(File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile Photo *',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),
        
        // Main profile photo
        Center(
          child: GestureDetector(
            onTap: onProfilePhotoTap,
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
              child: profilePhoto != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(75.r),
                      child: Image.file(
                        profilePhoto!,
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
        
        SizedBox(height: 24.h),
        
        // Additional photos
        Text(
          'Additional Photos (Optional)',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Add up to 5 more photos',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 16.h),
        
        SizedBox(
          height: 100.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: additionalPhotos.length + (additionalPhotos.length < 5 ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == additionalPhotos.length && additionalPhotos.length < 5) {
                // Add photo button
                return GestureDetector(
                  onTap: _pickAdditionalPhoto,
                  child: Container(
                    width: 100.w,
                    height: 100.h,
                    margin: EdgeInsets.only(right: 12.w),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppColors.border,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          size: 24.sp,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Add',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              // Photo item
              return Container(
                width: 100.w,
                height: 100.h,
                margin: EdgeInsets.only(right: 12.w),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Image.file(
                        additionalPhotos[index],
                        width: 100.w,
                        height: 100.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4.h,
                      right: 4.w,
                      child: GestureDetector(
                        onTap: () => onRemovePhoto(index),
                        child: Container(
                          width: 24.w,
                          height: 24.h,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.close,
                            size: 16.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}