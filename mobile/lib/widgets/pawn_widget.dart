import 'package:flutter/material.dart';
import '../models/pawn.dart';

class PawnWidget extends StatelessWidget {
  final Pawn pawn;
  final double size;
  final bool shouldHighlight;

  const PawnWidget({
    super.key,
    required this.pawn,
    required this.size,
    this.shouldHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    // Marble Gradient
    final gradient = RadialGradient(
      center: const Alignment(-0.4, -0.4),
      radius: 0.8,
      colors: [
        Colors.white.withOpacity(0.9), // Specular highlight
        pawn.color, // Main color
        Color.lerp(pawn.color, Colors.black, 0.4)!, // Shadow
      ],
      stops: const [0.0, 0.3, 1.0],
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        // 1. Selection Ripple (if moving)
        if (shouldHighlight)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(seconds: 1),
            builder: (context, val, child) {
              return Container(
                width: size * (0.8 + 0.3 * val),
                height: size * (0.8 + 0.3 * val),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(1 - val),
                    width: 2,
                  ),
                ),
              );
            },
            onEnd:
                () {}, // Loop handled by parent rebuilds usually, or keep simple
          ),

        // 2. Shadow underneath
        Container(
          width: size * 0.6,
          height: size * 0.6,
          margin: EdgeInsets.only(top: size * 0.1),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),

        // 3. The Marble Body
        Container(
          width: size * 0.7,
          height: size * 0.7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: gradient,
            boxShadow: [
              BoxShadow(
                color: pawn.color.withOpacity(0.4),
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
