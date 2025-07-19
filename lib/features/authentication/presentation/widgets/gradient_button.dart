import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GradientButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Gradient gradient;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool enabled;

  const GradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    required this.gradient,
    this.width,
    this.height,
    this.borderRadius,
    this.padding,
    this.enabled = true,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.enabled && widget.onPressed != null
          ? (_) {
              setState(() => _isPressed = true);
              _animationController.forward();
            }
          : null,
      onTapUp: widget.enabled && widget.onPressed != null
          ? (_) {
              setState(() => _isPressed = false);
              _animationController.reverse();
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: widget.enabled && widget.onPressed != null
          ? () {
              setState(() => _isPressed = false);
              _animationController.reverse();
            }
          : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width ?? double.infinity,
              height: widget.height ?? 56.h,
              decoration: BoxDecoration(
                gradient: widget.enabled
                    ? widget.gradient
                    : LinearGradient(
                        colors: [
                          Colors.grey.shade300,
                          Colors.grey.shade400,
                        ],
                      ),
                borderRadius: widget.borderRadius ?? BorderRadius.circular(12.r),
                boxShadow: widget.enabled && !_isPressed
                    ? [
                        BoxShadow(
                          color: widget.gradient.colors.first.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.enabled ? widget.onPressed : null,
                  borderRadius: widget.borderRadius ?? BorderRadius.circular(12.r),
                  child: Container(
                    padding: widget.padding ??
                        EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                    child: Center(child: widget.child),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}