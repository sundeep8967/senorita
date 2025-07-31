import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PhoneVerificationScreen extends StatefulWidget {
  const PhoneVerificationScreen({super.key});

  @override
  _PhoneVerificationScreenState createState() => _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0?q=80&w=2574&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Frosted Glass Effect
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          // UI
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                Text(
                  'Verify your number',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.w),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.r),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15.r),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: CupertinoTextField(
                          controller: _phoneController,
                          placeholder: 'Enter phone number',
                          keyboardType: TextInputType.phone,
                          placeholderStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                          style: const TextStyle(color: Colors.white),
                          decoration: const BoxDecoration(),
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                CupertinoButton.filled(
                  child: const Text('Continue'),
                  onPressed: () {
                    // TODO: Implement OTP sending logic
                  },
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
