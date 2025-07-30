import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';

class GlassmorphismTheme {
  // iOS-style glassmorphism colors
  static const Color glassBackground = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x2AFFFFFF);
  static const Color glassHighlight = Color(0x40FFFFFF);
  static const Color iosBlue = Color(0xFF007AFF);
  static const Color iosPink = Color(0xFFFF2D92);
  static const Color iosOrange = Color(0xFFFF9500);
  static const Color iosGreen = Color(0xFF30D158);
  
  // Premium gradients
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
      Color(0x20FFFFFF),
      Color(0x10FFFFFF),
    ],
  );
  
  // Glassmorphism container decoration
  static BoxDecoration glassContainer({
    double borderRadius = 16,
    Color? backgroundColor,
    Color? borderColor,
    double borderWidth = 1,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? glassBackground,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? glassBorder,
        width: borderWidth,
      ),
    );
  }
  
  // Glassmorphism card decoration
  static BoxDecoration glassCard({
    double borderRadius = 20,
    bool isDark = false,
  }) {
    return BoxDecoration(
      color: isDark ? const Color(0x40000000) : glassBackground,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: isDark ? const Color(0x33FFFFFF) : const Color(0x1AFFFFFF),
        width: 1,
      ),
    );
  }
  
  // Glassmorphism button decoration
  static BoxDecoration glassButton({
    double borderRadius = 25,
    bool isPressed = false,
  }) {
    return BoxDecoration(
      color: isPressed ? const Color(0x33FFFFFF) : glassBackground,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: glassBorder,
        width: 1,
      ),
    );
  }
  
  // App theme data
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0F0C29),
      primaryColor: Colors.white,
      colorScheme: const ColorScheme.dark(
        primary: Colors.white,
        secondary: Colors.white70,
        surface: Color(0x1AFFFFFF),
        background: Color(0xFF000000),
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: Colors.white,
        onBackground: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: glassBackground,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
            side: BorderSide(color: glassBorder),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: transparentWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderGlass),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderGlass),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white54),
      ),
    );
  }
}

// Glassmorphism container widget
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final bool blur;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1,
    this.blur = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget container = Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: GlassmorphismTheme.glassContainer(
        borderRadius: borderRadius,
        backgroundColor: backgroundColor,
        borderColor: borderColor,
        borderWidth: borderWidth,
      ),
      child: child,
    );

    if (blur) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: container,
        ),
      );
    }

    return container;
  }
}

// Glassmorphism button widget
class GlassButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  const GlassButton({
    super.key,
    required this.child,
    this.onPressed,
    this.borderRadius = 25,
    this.padding,
    this.width,
    this.height,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: widget.width,
        height: widget.height,
        padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: GlassmorphismTheme.glassButton(
          borderRadius: widget.borderRadius,
          isPressed: _isPressed,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Center(child: widget.child),
          ),
        ),
      ),
    );
  }
}