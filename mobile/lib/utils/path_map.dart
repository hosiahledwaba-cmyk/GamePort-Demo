import 'dart:ui';
import '../models/pawn.dart';

class PathMap {
  // Center of the board
  static const double cx = 7;
  static const double cy = 7;

  /// Returns the exact pixel coordinate for a pawn
  static Offset getPixelCoordinates(
    Pawn pawn,
    int playerIndex,
    double cellSize,
  ) {
    // 1. Base Position
    if (pawn.stepIndex == 0) {
      return _getBaseCoord(playerIndex, pawn.id) * cellSize;
    }

    // 2. Logic: Get Red's logical position (0-deg reference)
    //    This returns a coordinate on the generic 52-step track
    Offset redPos = _getRedPathCoord(pawn.stepIndex);

    // 3. Logic: Rotate that position for the current player
    Offset finalPos = _rotateForPlayer(redPos, playerIndex);

    return finalPos * cellSize;
  }

  /// Checks if a physical board coordinate is a "Star" (Safe Spot)
  static bool isSafeSpot(Offset pos) {
    // Round to handle float precision issues
    int x = pos.dx.round();
    int y = pos.dy.round();

    // The 8 Safe Stars on a standard 15x15 Ludo Board

    // 1. Colored Start Squares
    if (x == 1 && y == 6) return true; // Red Start
    if (x == 8 && y == 1) return true; // Green Start
    if (x == 13 && y == 8) return true; // Yellow Start
    if (x == 6 && y == 13) return true; // Blue Start

    // 2. The "Globe" Stars (8 steps from start)
    if (x == 6 && y == 2) return true;
    if (x == 12 && y == 6) return true;
    if (x == 8 && y == 12) return true;
    if (x == 2 && y == 8) return true;

    return false;
  }

  /// Rotates coordinates 90 degrees clockwise per player index
  static Offset _rotateForPlayer(Offset pos, int playerIndex) {
    if (playerIndex == 0) return pos;

    double x = pos.dx;
    double y = pos.dy;

    for (int i = 0; i < playerIndex; i++) {
      // 90 deg clockwise around (7,7)
      // NewX = 14 - y
      // NewY = x
      double oldX = x;
      x = 14 - y;
      y = oldX;
    }
    return Offset(x, y);
  }

  static Offset _getBaseCoord(int playerIndex, int pawnId) {
    double bx = 0, by = 0;
    switch (playerIndex) {
      case 0:
        bx = 1.5;
        by = 1.5;
        break; // Red (Top Left)
      case 1:
        bx = 10.5;
        by = 1.5;
        break; // Green (Top Right)
      case 2:
        bx = 10.5;
        by = 10.5;
        break; // Yellow (Bottom Right)
      case 3:
        bx = 1.5;
        by = 10.5;
        break; // Blue (Bottom Left)
    }
    double ox = (pawnId % 2) == 0 ? -0.5 : 0.5;
    double oy = (pawnId < 2) ? -0.5 : 0.5;
    return Offset(bx + ox, by + oy);
  }

  static Offset _getRedPathCoord(int step) {
    // Sanity check for invalid steps
    if (step < 1 || step > 57) return const Offset(7, 7);

    // RED'S MAIN PATH (Manually defined to skip Ghost Corners)
    // The path strictly follows the grid and jumps diagonally over the
    // invalid 3x3 void corners (e.g., skips (8,6) and jumps to (9,6)).
    const List<Offset> redPath = [
      // 1-5: Straight Right
      Offset(1, 6), Offset(2, 6), Offset(3, 6), Offset(4, 6), Offset(5, 6),
      // 6-11: Up Diagonal Arm
      Offset(6, 5),
      Offset(6, 4),
      Offset(6, 3),
      Offset(6, 2),
      Offset(6, 1),
      Offset(6, 0),
      // 12-13: Top Turn
      Offset(7, 0), Offset(8, 0),
      // 14-19: Down Diagonal Arm
      Offset(8, 1),
      Offset(8, 2),
      Offset(8, 3),
      Offset(8, 4),
      Offset(8, 5),
      Offset(8, 6),
      // 20-25: Right Straight Arm (Correction: 6 steps starting from 9,6)
      Offset(9, 6),
      Offset(10, 6),
      Offset(11, 6),
      Offset(12, 6),
      Offset(13, 6),
      Offset(14, 6),
      // 26-27: Right Turn
      Offset(14, 7), Offset(14, 8),
      // 28-33: Left Straight Arm
      Offset(13, 8),
      Offset(12, 8),
      Offset(11, 8),
      Offset(10, 8),
      Offset(9, 8),
      Offset(8, 8),
      // 34-39: Down Diagonal Arm
      Offset(8, 9),
      Offset(8, 10),
      Offset(8, 11),
      Offset(8, 12),
      Offset(8, 13),
      Offset(8, 14),
      // 40-41: Bottom Turn
      Offset(7, 14), Offset(6, 14),
      // 42-47: Up Diagonal Arm
      Offset(6, 13),
      Offset(6, 12),
      Offset(6, 11),
      Offset(6, 10),
      Offset(6, 9),
      Offset(6, 8),
      // 48-52: Left Straight Arm (The Approach)
      Offset(5, 8), Offset(4, 8), Offset(3, 8), Offset(2, 8), Offset(1, 8),
    ];

    // Note: step 52 is the last step of the outer loop (1,8)
    if (step <= 52) {
      return redPath[step - 1];
    }

    // HOME STRETCH (53-57)
    // Red enters home straight at Row 7, Cols 1-5
    // 53 -> (1,7) ... 57 -> (5,7)
    return Offset((step - 52).toDouble(), 7);
  }
}
