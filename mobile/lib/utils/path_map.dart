import 'package:flutter/material.dart';
import '../models/pawn.dart';

class PathMap {
  /// Converts logical pawn state into actual pixel Offset for the UI
  static Offset getPixelCoordinates(
    Pawn pawn,
    int playerIndex,
    double cellSize,
  ) {
    // 1. If in Base (Waiting to start)
    if (pawn.stepIndex == 0) {
      return _getBaseCoord(playerIndex, pawn.id) * cellSize;
    }

    // 2. If Home (Finished)
    if (pawn.stepIndex == 57) {
      return _getWinnerCoord(playerIndex, pawn.id) * cellSize;
    }

    // 3. If on the Path
    Offset gridPos = _getPathCoord(playerIndex, pawn.stepIndex);
    return gridPos * cellSize;
  }

  static Offset _getBaseCoord(int playerIndex, int pawnId) {
    // Defines the 2x2 grid inside each base
    double baseX = 0, baseY = 0;
    switch (playerIndex) {
      case 0:
        baseX = 1;
        baseY = 1;
        break; // Red (Top Left)
      case 1:
        baseX = 10;
        baseY = 1;
        break; // Green (Top Right)
      case 2:
        baseX = 10;
        baseY = 10;
        break; // Yellow (Bottom Right)
      case 3:
        baseX = 1;
        baseY = 10;
        break; // Blue (Bottom Left)
    }

    // Offset each pawn slightly in the 2x2 box
    int dx = pawnId % 2;
    int dy = pawnId ~/ 2;
    return Offset(baseX + dx * 2.0, baseY + dy * 2.0);
  }

  static Offset _getWinnerCoord(int playerIndex, int pawnId) {
    // Stacks them in the center triangle
    // Simplified center stacking for visual clarity
    return const Offset(7, 7);
  }

  static Offset _getPathCoord(int playerIndex, int stepIndex) {
    // Standard Ludo Path Logic
    // This is the generic path for Red (Player 0)
    // Other players just shift the index by 13

    // 1. Calculate global index on the 52-step outer loop
    if (stepIndex <= 51) {
      // Red starts at index 0 of the generic path
      // Green starts at 13, Yellow 26, Blue 39
      int globalIndex = (stepIndex - 1 + (playerIndex * 13)) % 52;
      return _outerPath[globalIndex];
    } else {
      // 2. Home Stretch (Steps 52-56)
      int distanceIn = stepIndex - 51;
      switch (playerIndex) {
        case 0:
          return Offset(distanceIn.toDouble(), 7); // Red goes Right
        case 1:
          return Offset(7, distanceIn.toDouble()); // Green goes Down
        case 2:
          return Offset(14 - distanceIn.toDouble(), 7); // Yellow goes Left
        case 3:
          return Offset(7, 14 - distanceIn.toDouble()); // Blue goes Up
      }
    }
    return const Offset(7, 7);
  }

  // The 52 squares of the outer loop, starting from Red's start position (1,6)
  static const List<Offset> _outerPath = [
    Offset(1, 6),
    Offset(2, 6),
    Offset(3, 6),
    Offset(4, 6),
    Offset(5, 6), // Red Approach
    Offset(6, 5),
    Offset(6, 4),
    Offset(6, 3),
    Offset(6, 2),
    Offset(6, 1),
    Offset(6, 0), // Up Top
    Offset(7, 0), Offset(8, 0), // Top Turn
    Offset(8, 1),
    Offset(8, 2),
    Offset(8, 3),
    Offset(8, 4),
    Offset(8, 5),
    Offset(8, 6), // Down Top
    Offset(9, 6),
    Offset(10, 6),
    Offset(11, 6),
    Offset(12, 6),
    Offset(13, 6),
    Offset(14, 6), // Right Side
    Offset(14, 7), Offset(14, 8), // Right Turn
    Offset(13, 8),
    Offset(12, 8),
    Offset(11, 8),
    Offset(10, 8),
    Offset(9, 8),
    Offset(8, 8), // Left from Right
    Offset(8, 9),
    Offset(8, 10),
    Offset(8, 11),
    Offset(8, 12),
    Offset(8, 13),
    Offset(8, 14), // Down Bottom
    Offset(7, 14), Offset(6, 14), // Bottom Turn
    Offset(6, 13),
    Offset(6, 12),
    Offset(6, 11),
    Offset(6, 10),
    Offset(6, 9),
    Offset(6, 8), // Up Bottom
    Offset(5, 8),
    Offset(4, 8),
    Offset(3, 8),
    Offset(2, 8),
    Offset(1, 8),
    Offset(0, 8), // Left Side
    Offset(0, 7), Offset(0, 6), // Left Turn (Back to Start)
  ];
}
