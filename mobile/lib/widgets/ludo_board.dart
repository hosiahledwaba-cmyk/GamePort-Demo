import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/game_controller.dart';
import '../models/pawn.dart';
import '../models/player.dart'; // Needed for PlayerType
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

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(10, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  // 1. Static Board
                  CustomPaint(
                    size: Size(boardSize, boardSize),
                    painter: BoardPainter(),
                  ),

                  // 2. Pawns
                  Consumer<GameController>(
                    builder: (context, game, child) {
                      return Stack(
                        children: game.players.expand((player) {
                          return player.pawns.map((pawn) {
                            final pos = PathMap.getPixelCoordinates(
                              pawn,
                              player.id,
                              cellSize,
                            );

                            // CHECK: Is this pawn interactable?
                            bool isMine = player.type == PlayerType.human;
                            bool canInteract = isMine && game.canMove(pawn);

                            return AnimatedPositioned(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOutBack,
                              left: pos.dx,
                              top: pos.dy,
                              width: cellSize,
                              height: cellSize,
                              child: GestureDetector(
                                onTap: canInteract
                                    ? () => game.movePawn(pawn)
                                    : null, // Disable click if not valid
                                child: PawnWidget(
                                  pawn: pawn,
                                  size: cellSize,
                                  shouldHighlight: canInteract,
                                ),
                              ),
                            );
                          });
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ... BoardPainter class remains exactly the same as previous response ...
class BoardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / 15;

    // --- 1. Draw The Bases (Corners) ---
    _drawBase(canvas, const Offset(0, 0), Colors.red, cellSize); // Top-Left
    _drawBase(canvas, const Offset(9, 0), Colors.green, cellSize); // Top-Right
    _drawBase(
      canvas,
      const Offset(9, 9),
      Colors.yellow,
      cellSize,
    ); // Bottom-Right
    _drawBase(canvas, const Offset(0, 9), Colors.blue, cellSize); // Bottom-Left

    // --- 2. Draw The Grid (Etched Glass Look) ---
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 15; i++) {
      for (int j = 0; j < 15; j++) {
        // Skip base areas
        if ((i < 6 && j < 6) ||
            (i > 8 && j < 6) ||
            (i < 6 && j > 8) ||
            (i > 8 && j > 8))
          continue;
        // Skip center
        if (i >= 6 && i <= 8 && j >= 6 && j <= 8) continue;

        canvas.drawRect(
          Rect.fromLTWH(i * cellSize, j * cellSize, cellSize, cellSize),
          gridPaint,
        );
      }
    }

    // --- 3. Draw Colored Home Paths ---
    _drawColoredPath(canvas, 1, 7, 5, 1, Colors.red, cellSize);
    _drawColoredPath(canvas, 7, 1, 1, 5, Colors.green, cellSize);
    _drawColoredPath(canvas, 9, 7, 5, 1, Colors.yellow, cellSize);
    _drawColoredPath(canvas, 7, 9, 1, 5, Colors.blue, cellSize);

    // --- 4. Draw Safe Spots ---
    _drawSafeSpot(canvas, 1, 6, Colors.red, cellSize);
    _drawSafeSpot(canvas, 8, 1, Colors.green, cellSize);
    _drawSafeSpot(canvas, 13, 8, Colors.yellow, cellSize);
    _drawSafeSpot(canvas, 6, 13, Colors.blue, cellSize);

    _drawSafeSpot(canvas, 6, 2, Colors.white, cellSize);
    _drawSafeSpot(canvas, 12, 6, Colors.white, cellSize);
    _drawSafeSpot(canvas, 8, 12, Colors.white, cellSize);
    _drawSafeSpot(canvas, 2, 8, Colors.white, cellSize);

    // --- 5. Center Home Triangle ---
    _drawCenterTriangles(canvas, size, cellSize);
  }

  void _drawBase(
    Canvas canvas,
    Offset startCoords,
    Color color,
    double cellSize,
  ) {
    final paint = Paint()..color = color.withOpacity(0.2);
    final rect = Rect.fromLTWH(
      startCoords.dx * cellSize,
      startCoords.dy * cellSize,
      6 * cellSize,
      6 * cellSize,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(2), const Radius.circular(16)),
      paint,
    );

    final innerPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final innerRect = Rect.fromLTWH(
      (startCoords.dx + 1) * cellSize,
      (startCoords.dy + 1) * cellSize,
      4 * cellSize,
      4 * cellSize,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(innerRect, const Radius.circular(12)),
      innerPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(innerRect, const Radius.circular(12)),
      borderPaint,
    );
  }

  void _drawColoredPath(
    Canvas canvas,
    int x,
    int y,
    int w,
    int h,
    Color color,
    double cellSize,
  ) {
    final paint = Paint()..color = color.withOpacity(0.25);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x * cellSize, y * cellSize, w * cellSize, h * cellSize),
        const Radius.circular(4),
      ),
      paint,
    );
  }

  void _drawSafeSpot(
    Canvas canvas,
    int x,
    int y,
    Color color,
    double cellSize,
  ) {
    final paint = Paint()..color = color.withOpacity(0.3);
    canvas.drawRect(
      Rect.fromLTWH(x * cellSize, y * cellSize, cellSize, cellSize),
      paint,
    );

    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(Icons.star_rounded.codePoint),
        style: TextStyle(
          fontSize: cellSize * 0.7,
          fontFamily: Icons.star_rounded.fontFamily,
          color: Colors.white.withOpacity(0.8),
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(
        x * cellSize + (cellSize - iconPainter.width) / 2,
        y * cellSize + (cellSize - iconPainter.height) / 2,
      ),
    );
  }

  void _drawCenterTriangles(Canvas canvas, Size size, double cellSize) {
    final paint = Paint()..style = PaintingStyle.fill;
    paint.color = Colors.red.withOpacity(0.2);
    canvas.drawPath(
      Path()
        ..moveTo(6 * cellSize, 6 * cellSize)
        ..lineTo(6 * cellSize, 9 * cellSize)
        ..lineTo(7.5 * cellSize, 7.5 * cellSize)
        ..close(),
      paint,
    );
    paint.color = Colors.green.withOpacity(0.2);
    canvas.drawPath(
      Path()
        ..moveTo(6 * cellSize, 6 * cellSize)
        ..lineTo(9 * cellSize, 6 * cellSize)
        ..lineTo(7.5 * cellSize, 7.5 * cellSize)
        ..close(),
      paint,
    );
    paint.color = Colors.yellow.withOpacity(0.2);
    canvas.drawPath(
      Path()
        ..moveTo(9 * cellSize, 6 * cellSize)
        ..lineTo(9 * cellSize, 9 * cellSize)
        ..lineTo(7.5 * cellSize, 7.5 * cellSize)
        ..close(),
      paint,
    );
    paint.color = Colors.blue.withOpacity(0.2);
    canvas.drawPath(
      Path()
        ..moveTo(6 * cellSize, 9 * cellSize)
        ..lineTo(9 * cellSize, 9 * cellSize)
        ..lineTo(7.5 * cellSize, 7.5 * cellSize)
        ..close(),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
