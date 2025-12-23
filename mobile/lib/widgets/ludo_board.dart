import 'dart:ui';
import 'dart:math'; // Added for pi, cos, sin
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/game_controller.dart';
import '../models/pawn.dart';
import '../models/player.dart';
import '../utils/path_map.dart';
import 'pawn_widget.dart';

class LudoBoard extends StatelessWidget {
  const LudoBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final boardSize = constraints.maxWidth;
          final cellSize = boardSize / 15;

          return ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Stack(
              children: [
                // --- Glass Blur Base ---
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.25),
                          Colors.white.withOpacity(0.05),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.35),
                        width: 1.2,
                      ),
                    ),
                  ),
                ),

                // --- Inner Glow / Shadow ---
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.12),
                        blurRadius: 40,
                        spreadRadius: 0, // Fixed: Removed invalid 'inset'
                      ),
                    ],
                  ),
                ),

                // --- Board Paint ---
                CustomPaint(
                  size: Size(boardSize, boardSize),
                  painter: BoardPainter(),
                ),

                // --- Pawns ---
                Consumer<GameController>(
                  builder: (context, game, _) {
                    final List<_PawnRender> all = [];

                    for (final player in game.players) {
                      for (final pawn in player.pawns) {
                        all.add(_PawnRender(pawn, player));
                      }
                    }

                    // Stable sort: non-current first, current player on top
                    all.sort((a, b) {
                      final cId = game.players[game.currentPlayerIndex].id;
                      bool aIsCurrent = a.player.id == cId;
                      bool bIsCurrent = b.player.id == cId;

                      if (aIsCurrent && !bIsCurrent) return 1;
                      if (!aIsCurrent && bIsCurrent) return -1;

                      if (a.player.id != b.player.id) {
                        return a.player.id.compareTo(b.player.id);
                      }
                      return a.pawn.id.compareTo(b.pawn.id);
                    });

                    final Map<String, int> stacks = {};
                    final List<Widget> widgets = [];

                    for (final data in all) {
                      final pawn = data.pawn;
                      final player = data.player;

                      final pos = PathMap.getPixelCoordinates(
                        pawn,
                        player.id,
                        cellSize,
                      );

                      final key = '${pos.dx.round()}_${pos.dy.round()}';
                      final index = stacks[key] ?? 0;
                      stacks[key] = index + 1;

                      // Radial stacking (prettier & clearer)
                      final angle = index * (pi / 2.5); // Adjusted spread
                      final radius = index == 0 ? 0.0 : cellSize * 0.18;
                      final offset = Offset(
                        cos(angle) * radius,
                        sin(angle) * radius,
                      );

                      final canTap =
                          player.type == PlayerType.human && game.canMove(pawn);

                      widgets.add(
                        AnimatedPositioned(
                          key: ValueKey('pawn_${player.id}_${pawn.id}'),
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeOutCubic,
                          left: pos.dx + offset.dx,
                          top: pos.dy + offset.dy,
                          width: cellSize,
                          height: cellSize,
                          child: GestureDetector(
                            behavior: canTap
                                ? HitTestBehavior.opaque
                                : HitTestBehavior.deferToChild,
                            onTap: canTap ? () => game.movePawn(pawn) : null,
                            child: PawnWidget(
                              pawn: pawn,
                              size: cellSize,
                              shouldHighlight: canTap,
                            ),
                          ),
                        ),
                      );
                    }

                    return Stack(children: widgets);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/* ---------------------------- HELPERS ---------------------------- */

class _PawnRender {
  final Pawn pawn;
  final Player player;
  _PawnRender(this.pawn, this.player);
}

/* ---------------------------- BOARD PAINTER ---------------------------- */

class BoardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 15;

    // 1. Bases
    _drawBase(canvas, const Offset(0, 0), Colors.red, s);
    _drawBase(canvas, const Offset(9, 0), Colors.green, s);
    _drawBase(canvas, const Offset(9, 9), Colors.yellow, s);
    _drawBase(canvas, const Offset(0, 9), Colors.blue, s);

    final grid = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // 2. Grid (Skipping Void/Ghost corners)
    for (int x = 0; x < 15; x++) {
      for (int y = 0; y < 15; y++) {
        if (_isVoid(x, y)) continue; // Ensure no ghost grids
        canvas.drawRect(Rect.fromLTWH(x * s, y * s, s, s), grid);
      }
    }

    // 3. Elements
    _drawPaths(canvas, s);
    _drawSafeSpots(canvas, s);
    _drawCenter(canvas, s);
  }

  // Ensures the 3x3 Center and Bases are excluded from generic grid drawing
  bool _isVoid(int x, int y) {
    if (x < 6 && y < 6) return true; // Top Left Base
    if (x > 8 && y < 6) return true; // Top Right Base
    if (x < 6 && y > 8) return true; // Bottom Left Base
    if (x > 8 && y > 8) return true; // Bottom Right Base
    if (x >= 6 && x <= 8 && y >= 6 && y <= 8)
      return true; // Center & Ghost Corners
    return false;
  }

  void _drawBase(Canvas canvas, Offset o, Color c, double s) {
    final r = Rect.fromLTWH(o.dx * s, o.dy * s, 6 * s, 6 * s);
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(18)),
      Paint()..color = c.withOpacity(0.18),
    );
  }

  void _drawPaths(Canvas canvas, double s) {
    void p(int x, int y, int w, int h, Color c) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x * s, y * s, w * s, h * s),
          const Radius.circular(6),
        ),
        Paint()..color = c.withOpacity(0.28),
      );
    }

    p(1, 7, 5, 1, Colors.red);
    p(7, 1, 1, 5, Colors.green);
    p(9, 7, 5, 1, Colors.yellow);
    p(7, 9, 1, 5, Colors.blue);
  }

  void _drawSafeSpots(Canvas canvas, double s) {
    final spots = [
      const Offset(1, 6),
      const Offset(8, 1),
      const Offset(13, 8),
      const Offset(6, 13),
      const Offset(6, 2),
      const Offset(12, 6),
      const Offset(8, 12),
      const Offset(2, 8),
    ];

    final paint = Paint()..color = Colors.white.withOpacity(0.25);
    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(Icons.star_rounded.codePoint),
        style: TextStyle(
          fontSize: s * 0.7,
          fontFamily: Icons.star_rounded.fontFamily,
          color: Colors.white.withOpacity(0.8),
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    iconPainter.layout();

    for (final p in spots) {
      canvas.drawRect(Rect.fromLTWH(p.dx * s, p.dy * s, s, s), paint);
      iconPainter.paint(
        canvas,
        Offset(
          p.dx * s + (s - iconPainter.width) / 2,
          p.dy * s + (s - iconPainter.height) / 2,
        ),
      );
    }
  }

  void _drawCenter(Canvas canvas, double s) {
    final center = Offset(7.5 * s, 7.5 * s);
    final colors = [Colors.red, Colors.green, Colors.yellow, Colors.blue];

    // Triangle coordinates covering the ghost corner gaps
    final angles = [
      [Offset(6, 6), Offset(6, 9)], // Red side
      [Offset(6, 6), Offset(9, 6)], // Green side
      [Offset(9, 6), Offset(9, 9)], // Yellow side
      [Offset(6, 9), Offset(9, 9)], // Blue side
    ];

    for (int i = 0; i < 4; i++) {
      final path = Path()
        ..moveTo(angles[i][0].dx * s, angles[i][0].dy * s)
        ..lineTo(angles[i][1].dx * s, angles[i][1].dy * s)
        ..lineTo(center.dx, center.dy)
        ..close();

      canvas.drawPath(path, Paint()..color = colors[i].withOpacity(0.22));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
