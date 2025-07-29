import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';

class IOSGlassmorphismTheme {
  // iOS-style colors
  static const Color iosBlue = Color(0xFF007AFF);
  static const Color iosPink = Color(0xFFFF2D92);
  static const Color iosOrange = Color(0xFFFF9500);
  static const Color iosGreen = Color(0xFF30D158);
  static const Color iosRed = Color(0xFFFF3B30);
  static const Color iosPurple = Color(0xFFAF52DE);
  static const Color iosYellow = Color(0xFFFFCC00);
  
  // Glass colors
  static const Color glassBackground = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x2AFFFFFF);
  static const Color glassHighlight = Color(0x40FFFFFF);
  static const Color glassShadow = Color(0x20000000);
  
  // Background gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF6B9D),
      Color(0xFFC44569),
      Color(0xFF6C5CE7),
    ],
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0F0C29),
      Color(0xFF24243e),
      Color(0xFF302B63),
    ],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x25FFFFFF),
      Color(0x15FFFFFF),
    ],
  );
  
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x30FFFFFF),
      Color(0x10FFFFFF),
    ],
  );

  // Main theme
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0F0C29),
      primaryColor: iosBlue,
      fontFamily: 'SF Pro Display',
      colorScheme: const ColorScheme.dark(
        primary: iosBlue,
        secondary: iosPink,
        surface: Color(0x1AFFFFFF),
        background: Color(0xFF0F0C29),
        error: iosRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onBackground: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 22.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 34.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: -1.0,
        ),
        headlineMedium: TextStyle(
          fontSize: 28.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
        headlineSmall: TextStyle(
          fontSize: 22.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: -0.3,
        ),
        titleLarge: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: -0.2,
        ),
        titleMedium: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          letterSpacing: -0.2,
        ),
        bodyLarge: TextStyle(
          fontSize: 17.sp,
          fontWeight: FontWeight.w400,
          color: Colors.white.withValues(alpha: 0.9),
          letterSpacing: -0.2,
        ),
        bodyMedium: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w400,
          color: Colors.white.withValues(alpha: 0.8),
          letterSpacing: -0.1,
        ),
        bodySmall: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w400,
          color: Colors.white.withValues(alpha: 0.7),
          letterSpacing: -0.1,
        ),
      ),
    );
  }
  
  // Glass container decoration
  static BoxDecoration glassContainer({
    double borderRadius = 20,
    Color? borderColor,
    double borderWidth = 1.5,
    bool hasInnerShadow = true,
  }) {
    return BoxDecoration(
      gradient: cardGradient,
      borderRadius: BorderRadius.circular(borderRadius.r),
      border: Border.all(
        color: borderColor ?? glassBorder,
        width: borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: glassShadow,
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        if (hasInnerShadow)
          BoxShadow(
            color: glassHighlight,
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
      ],
    );
  }
  
  // iOS-style blur effect
  static Widget glassBlur({
    required Widget child,
    double sigmaX = 15,
    double sigmaY = 15,
    double borderRadius = 20,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
        child: child,
      ),
    );
  }
  
  // Premium button decoration
  static BoxDecoration premiumButton({
    Gradient? gradient,
    double borderRadius = 20,
    Color? shadowColor,
  }) {
    return BoxDecoration(
      gradient: gradient ?? primaryGradient,
      borderRadius: BorderRadius.circular(borderRadius.r),
      boxShadow: [
        BoxShadow(
          color: (shadowColor ?? iosPink).withValues(alpha: 0.4),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.1),
          blurRadius: 1,
          offset: const Offset(0, 1),
        ),
      ],
    );
  }
  
  // iOS-style card decoration
  static BoxDecoration iosCard({
    double borderRadius = 16,
    Color? backgroundColor,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? glassBackground,
      borderRadius: BorderRadius.circular(borderRadius.r),
      border: Border.all(
        color: glassBorder,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: glassShadow,
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
  
  // iOS-style input decoration
  static InputDecoration iosInput({
    String? hintText,
    IconData? prefixIcon,
    IconData? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.white.withValues(alpha: 0.6),
        fontSize: 16.sp,
      ),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: Colors.white.withValues(alpha: 0.7))
          : null,
      suffixIcon: suffixIcon != null
          ? Icon(suffixIcon, color: Colors.white.withValues(alpha: 0.7))
          : null,
      filled: true,
      fillColor: glassBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: glassBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: glassBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: iosBlue, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 16.h,
      ),
    );
  }
}