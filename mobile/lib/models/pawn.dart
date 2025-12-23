import 'dart:ui';

class Pawn {
  final int id;
  final int playerId;
  final Color color;

  // 0 = Base
  // 1-51 = Main Path
  // 52-56 = Home Stretch
  // 57 = Home
  int stepIndex;

  Pawn({
    required this.id,
    required this.playerId,
    required this.color,
    this.stepIndex = 0,
  });

  bool get isHome => stepIndex == 57;
  bool get inBase => stepIndex == 0;

  // Safe spots relative to stepIndex
  // Starts (1), Stars (9, 14, 22, 27, 35, 40, 48)
  bool get isSafe =>
      stepIndex == 0 ||
      stepIndex == 1 ||
      stepIndex == 9 ||
      stepIndex == 14 ||
      stepIndex == 22 ||
      stepIndex == 27 ||
      stepIndex == 35 ||
      stepIndex == 40 ||
      stepIndex == 48 ||
      stepIndex > 51; // Home stretch is safe
}
