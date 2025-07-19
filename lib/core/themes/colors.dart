import 'package:flutter/material.dart';

class AppColors {
  // Glassmorphism Primary Colors
  static const Color primary = Color(0xFFFFFFFF);
  static const Color primaryDark = Color(0xFFE0E0E0);
  static const Color primaryLight = Color(0xFFFFFFFF);
  
  // Glassmorphism Background Colors
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0x1AFFFFFF);
  static const Color surfaceVariant = Color(0x0DFFFFFF);
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0x1AFFFFFF);
  
  // Glassmorphism Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF);
  static const Color textHint = Color(0x80FFFFFF);
  static const Color textOnPrimary = Color(0xFF000000);
  
  // Status Colors (with glassmorphism touch)
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Glassmorphism Border Colors
  static const Color border = Color(0x33FFFFFF);
  static const Color divider = Color(0x1AFFFFFF);
  
  // Special Colors
  static const Color online = Color(0xFF4CAF50);
  static const Color offline = Color(0xFF9E9E9E);
  static const Color premium = Color(0xFFFFD700);
  
  // Secondary Colors
  static const Color secondary = Color(0xB3FFFFFF);
  static const Color secondaryLight = Color(0x80FFFFFF);
  static const Color secondaryDark = Color(0xFFFFFFFF);
  
  // Accent Colors
  static const Color accent = Color(0xFFFFFFFF);
  static const Color accentLight = Color(0x80FFFFFF);
  
  // Glassmorphism specific colors
  static const Color glassWhite = Color(0x1AFFFFFF);
  static const Color glassBlack = Color(0x40000000);
  static const Color glassBorder = Color(0x33FFFFFF);
  
  // Glassmorphism Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0x33FFFFFF), Color(0x1AFFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0x1AFFFFFF), Color(0x0DFFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF000000), Color(0xFF1A1A1A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}