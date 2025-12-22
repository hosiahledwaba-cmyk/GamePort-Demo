import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final double width;
  final double height;
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const GlassContainer({
    super.key,
    required this.child,
    this.width = double.infinity,
    this.height = double.infinity,
    this.blur = 15.0,
    this.opacity = 0.2,
    this.borderRadius,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderR = borderRadius ?? BorderRadius.circular(20);

    return ClipRRect(
      borderRadius: borderR,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: width,
            height: height,
            padding: padding ?? const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(opacity),
              borderRadius: borderR,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: -5,
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// A vibrant animated background wrapper
class LiquidBackground extends StatelessWidget {
  final Widget child;
  const LiquidBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Static vibrant gradient (can be animated later)
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF8E2DE2), // Deep Purple
                Color(0xFF4A00E0), // Blue-Purple
                Color(0xFF00C6FF), // Cyan
              ],
            ),
          ),
        ),
        // Floating Orbs for depth
        Positioned(
          top: -100,
          left: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.purpleAccent.withOpacity(0.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.purpleAccent.withOpacity(0.6),
                  blurRadius: 100,
                  spreadRadius: 50,
                ),
              ],
            ),
          ),
        ),
        child,
      ],
    );
  }
}
