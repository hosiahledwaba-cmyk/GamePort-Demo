import 'dart:ui';

class Pawn {
  final int id;
  final int playerId;
  final Color color;

  /// 0 = In Base
  /// 1..51 = On Common Path
  /// 52..56 = Final Home Stretch
  /// 57 = Home (Goal)
  int stepIndex;

  Pawn({
    required this.id,
    required this.playerId,
    required this.color,
    this.stepIndex = 0, // Starts in base
  });

  bool get isHome => stepIndex == 57;
  bool get inBase => stepIndex == 0;

  // Safe spots are usually stars or colored globe stops
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
      isHome;
}
