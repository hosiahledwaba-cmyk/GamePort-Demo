import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/game_controller.dart';
import '../models/player.dart';

class DiceWidget extends StatefulWidget {
  const DiceWidget({super.key});

  @override
  State<DiceWidget> createState() => _DiceWidgetState();
}

class _DiceWidgetState extends State<DiceWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600), // Slower, heavier glass feel
    );
    // Rotating on 3 axis simulation
    _rotationAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameController>(
      builder: (context, game, child) {
        final isMyTurn =
            game.players[game.currentPlayerIndex].type == PlayerType.human;
        final isRolling = game.phase == GamePhase.rolling;

        if (isRolling && _controller.status != AnimationStatus.forward) {
          _controller.forward(from: 0);
        }

        return GestureDetector(
          onTap: (isMyTurn && isRolling) ? game.rollDice : null,
          child: AnimatedBuilder(
            animation: _rotationAnim,
            builder: (context, child) {
              final angle = _rotationAnim.value * 2 * pi;

              return Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // Perspective
                  ..rotateZ(angle)
                  ..rotateY(angle * 0.5), // Tumble effect
                alignment: Alignment.center,
                child: Container(
                  width: 85,
                  height: 85,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    // GLASS MATERIAL EFFECT
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.6), // Shiny Top Left
                        Colors.white.withOpacity(0.1), // Clear Bottom Right
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.6), // Rim lighting
                      width: 1.5,
                    ),
                    boxShadow: [
                      // Deep shadow for 3D float
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(5, 10),
                      ),
                      // Inner glow (Caustics simulation)
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: -2,
                        offset: const Offset(-3, -3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 5,
                        sigmaY: 5,
                      ), // Frosted glass
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1), // Tint
                        ),
                        child: CustomPaint(
                          painter: GlassDicePainter(
                            value: game.currentDiceValue,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class GlassDicePainter extends CustomPainter {
  final int value;
  GlassDicePainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    // "Etched" look for dots
    // We draw a dark circle, then a smaller white highlight to make it look carved in
    final center = size.center(Offset.zero);
    final double r = size.width / 11; // Dot radius

    // Grid Positions
    final left = size.width * 0.25;
    final right = size.width * 0.75;
    final top = size.height * 0.25;
    final bottom = size.height * 0.75;

    final List<Offset> dots = [];

    switch (value) {
      case 1:
        dots.add(center);
        break;
      case 2:
        dots.addAll([Offset(left, top), Offset(right, bottom)]);
        break;
      case 3:
        dots.addAll([Offset(left, top), center, Offset(right, bottom)]);
        break;
      case 4:
        dots.addAll([
          Offset(left, top),
          Offset(right, top),
          Offset(left, bottom),
          Offset(right, bottom),
        ]);
        break;
      case 5:
        dots.addAll([
          Offset(left, top),
          Offset(right, top),
          center,
          Offset(left, bottom),
          Offset(right, bottom),
        ]);
        break;
      case 6:
        dots.addAll([
          Offset(left, top),
          Offset(right, top),
          Offset(left, center.dy),
          Offset(right, center.dy),
          Offset(left, bottom),
          Offset(right, bottom),
        ]);
        break;
    }

    for (var dot in dots) {
      // 1. Dark Etch (Shadow inside)
      canvas.drawCircle(dot, r, Paint()..color = Colors.black.withOpacity(0.5));

      // 2. White Highlight (Rim of the carve)
      canvas.drawArc(
        Rect.fromCircle(center: dot, radius: r),
        0,
        pi,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.white.withOpacity(0.4)
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant GlassDicePainter oldDelegate) =>
      oldDelegate.value != value;
}
